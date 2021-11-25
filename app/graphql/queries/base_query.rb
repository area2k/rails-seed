# frozen_string_literal: true

module Queries
  class BaseQuery < GraphQL::Schema::Resolver
    include ArgumentLoader
    include AuthHelpers
    include ErrorHelpers
  end
end
