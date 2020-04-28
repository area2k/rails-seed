# frozen_string_literal: true

module Queries
  class CurrentUserQuery < BaseQuery
    description 'Get current user'
    type Types::UserType, null: false

    def resolve
      current_user
    end

    def ready?(**)
      allow! authenticated?
    end
  end
end
