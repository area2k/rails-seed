# frozen_string_literal: true

module Mutations
  class ForgotPassword < BaseMutation
    description 'Allow a user matching the given email to reset their password'
    type Scalars::Void
    null true

    argument :email, Scalars::Email, required: true

    def monadic_resolve(email:)
      maybe_find(User, email: email).fmap do |user|
        user.update!(password_reset_token: SecureRandom.base36)

        # TODO: send forgot password email

        Success()
      end
    end
  end
end
