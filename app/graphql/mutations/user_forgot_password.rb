# frozen_string_literal: true

module Mutations
  class UserForgotPassword < BaseMutation
    description 'Allow a user matching the given email to reset their password'
    type Scalars::Void
    null true

    argument :email, Scalars::Email, required: true

    def resolve(email:)
      maybe_find(User, email: email).fmap do |user|
        user.update!(password_reset_token: SecureRandom.hex)

        # TODO: send reset password email
      end
    end
  end
end
