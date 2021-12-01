# frozen_string_literal: true

module Mutations
  class DeviceRefreshToken < BaseMutation
    description 'Exchange a refresh token for a new access token'

    argument :refresh_token, String, required: true, autofetch: :fetch_device, as: :device

    field :access_token, String, null: true
    field :refresh_token, String, null: true

    Problems = define_problems(
      DEVICE_EXPIRED: {
        description: 'Occurs when a device is no longer able to be refreshed',
        path: %w[]
      },
      INVALID_TOKEN: {
        description: 'Occurs when the given refreshToken is invalid',
        path: %w[refreshToken]
      }
    )

    def resolve(device:)
      token = AuthenticationService.refresh(device, **request_attrs)

      { access_token: token.to_s, refresh_token: device.refresh_token }
    end

    private

    def fetch_device(refresh_token)
      Device.find_by(refresh_token: refresh_token).tap do |device|
        raise Problems::INVALID_TOKEN if device.nil?
        raise Problems::DEVICE_EXPIRED if device.expired?
      end
    end

    def request_attrs
      context[:request].slice(:client, :client_version, :ip, :user_agent)
    end
  end
end
