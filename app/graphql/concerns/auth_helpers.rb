# frozen_string_literal: true

module AuthHelpers
  extend ActiveSupport::Concern

  def allow!(passed)
    return true if passed

    error! message: 'Authorization failed', code: :AUTHORIZATION_FAILED
  end

  def authenticated?
    context[:user_id].present?
  end

  def current_user
    context[:user] ||= User.find(context[:user_id])
  end
end
