# frozen_string_literal: true

module Mutations
  class UserResetPassword < BaseMutation
    description 'Reset password of user matching the given token'

    argument :token, String, required: true, autofetch: :fetch_user, as: :user
    argument :password, String, required: true

    Problems = define_problems(
      INVALID_TOKEN: {
        description: 'Occurs when the given token is invalid',
        path: %w[token]
      }
    )

    def resolve(user:, password:)
      user.update!(password: password, password_reset_token: nil, password_stale: false)

      { problem: nil }
    end

    private

    def fetch_user(token)
      User.find_by(password_reset_token: token).tap do |user|
        raise Problems::INVALID_TOKEN if user.nil?
      end
    end
  end
end
