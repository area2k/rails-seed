# frozen_string_literal: true

module Mutations
  class Login < BaseMutation
    description 'Obtain access tokens with user credentials'

    argument :email, Scalars::Email, required: true
    argument :password, String, required: true

    field :access_token, String, null: false
    field :refresh_token, String, null: false
    field :user, Types::UserType, null: false

    def resolve(email:, password:)
      user = User.find_by(email: email)
      invalid_login! unless user&.valid_password?(password)

      device = user.devices.create!(**request_attrs)
      token = AuthenticationService.issue(device_id, jti: device.last_issued)

      { access_token: token.to_s, refresh_token: device.refresh_token, user: user }
    end

    private

    def invalid_login!
      error! message: 'Invalid login', code: :INVALID_LOGIN
    end

    def request_attrs
      context[:request].slice(:client, :client_version, :ip, :user_agent)
    end
  end
end
