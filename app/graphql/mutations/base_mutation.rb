# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    include AuthHelpers
    include CustomArgumentLoader
    include ErrorHelpers
    include Finders
    include MonadicResolver

    class << self
      def default_graphql_name
        name.split('::').last
      end
    end

    protected

    def with_void_return(&block)
      nil.tap(&block)
    end
  end
end
