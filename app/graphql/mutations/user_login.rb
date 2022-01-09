# frozen_string_literal: true

module Mutations
  class UserLogin < BaseMutation
    description 'Obtain a device token with user credentials'

    argument :email, Scalars::Email, required: true
    argument :password, String, required: true

    field :device_token, String, null: true
    field :user, Types::UserType, null: true

    define_problems do
      problem :invalid_login, path: %w[],
        description: 'Occurs when the login credentials are incorrect or do not exist'
    end

    def resolve(email:, password:)
      user = User.find_by(email:)
      raise Problems::INVALID_LOGIN unless user&.valid_password?(password)

      device = user.devices.create!(**request_attrs)

      { device_token: device.refresh_token, user: }
    end
  end
end
