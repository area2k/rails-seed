# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    include ArgumentLoader
    include AuthHelpers
    include ErrorHelpers
    include MonadicResolver

    field_class Field

    null false

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
