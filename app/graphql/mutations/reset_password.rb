# frozen_string_literal: true

module Mutations
  class ResetPassword < BaseMutation
    description 'Reset password of user matching the given token'
    type Scalars::Void
    null true

    argument :token, String, required: true
    argument :password, String, required: true

    def monadic_resolve(token:, password:)
      user = yield monadic_find(User, password_reset_token: token)
      user.update!(password: password, password_reset_token: nil, password_stale: false)

      Success()
    end
  end
end
