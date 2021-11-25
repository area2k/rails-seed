# frozen_string_literal: true

module Mutations
  ResetPasswordProblem = make_problem_type('ResetPassword') do
    value 'INVALID_TOKEN',
      description: 'Occurs when the given token is invalid'
  end

  class ResetPassword < BaseMutation
    description 'Reset password of user matching the given token'

    argument :token, String, required: true, autofetch: :fetch_user, as: :user
    argument :password, String, required: true

    field :problem, ResetPasswordProblem, null: true

    INVALID_TOKEN_PROBLEM = Problem.new('INVALID_TOKEN', path: %w[token]).freeze

    def monadic_resolve(user:, password:)
      user.update!(password: password, password_reset_token: nil, password_stale: false)

      Success(problem: nil)
    end

    private

    def fetch_user(token)
      User.find_by(password_reset_token: token).tap do |user|
        raise INVALID_TOKEN_PROBLEM if user.nil?
      end
    end
  end
end
