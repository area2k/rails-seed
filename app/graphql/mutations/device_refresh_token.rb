# frozen_string_literal: true

module Mutations
  DeviceRefreshTokenProblem = make_problem_type('DeviceRefreshToken') do
    value 'DEVICE_EXPIRED',
      description: 'Occurs when a device is no longer able to be refreshed'
    value 'INVALID_TOKEN',
      description: 'Occurs when the given refreshToken is invalid'
  end

  class DeviceRefreshToken < BaseMutation
    description 'Exchange a refresh token for a new access token'

    argument :refresh_token, String, required: true, autofetch: :fetch_device, as: :device

    field :access_token, String, null: true
    field :refresh_token, String, null: true
    field :problem, DeviceRefreshTokenProblem, null: true

    DEVICE_EXPIRED_PROBLEM = Problem.new('DEVICE_EXPIRED', path: %w[]).freeze
    INVALID_TOKEN_PROBLEM = Problem.new('INVALID_TOKEN', path: %w[refreshToken]).freeze

    def monadic_resolve(device:)
      token = AuthenticationService.refresh(device, **request_attrs)

      Success(access_token: token.to_s, refresh_token: device.refresh_token)
    end

    private

    def fetch_device(refresh_token)
      Device.find_by(refresh_token: refresh_token).tap do |device|
        raise INVALID_TOKEN_PROBLEM if device.nil?
        raise DEVICE_EXPIRED_PROBLEM if device.expired?
      end
    end

    def request_attrs
      context[:request].slice(:client, :client_version, :ip, :user_agent)
    end
  end
end
