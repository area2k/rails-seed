# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    class_attribute :allowed_actors

    connection_type_class Connections::BaseConnection
    edge_type_class Connections::BaseEdge
    field_class Field

    class << self
      def allow_actors(*actors)
        self.allowed_actors = actors
      end

      def paginated
        type = self

        @paginated ||=
          Class.new(BaseObject) do
            description "Pagination container for #{type.graphql_name}"
            graphql_name "#{type.graphql_name}Page"

            field :items, [type], null: false
            field :page_info, PageInfoType, null: false
          end
      end

      def visible?(context)
        return super unless allowed_actors.present?

        super && context[:authenticated?] && context[:auth].actor_is?(*@allowed_actors)
      end
    end
  end
end
