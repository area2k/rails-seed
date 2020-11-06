# frozen_string_literal: true

module Queries
  class BaseQuery < GraphQL::Schema::Resolver
    include AuthHelpers
    include CustomArgumentLoader
    include ErrorHelpers
    include Finders
    include MonadResolver
  end
end
