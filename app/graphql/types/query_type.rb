# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    description 'The query root of this schema'
    graphql_name 'Query'

    (Queries.constants - %i[BaseQuery]).each do |query_name|
      field_name = query_name.to_s.underscore.delete_suffix('_query')
      resolver = Queries.const_get(query_name)

      field field_name, resolver: resolver, allow_actors: resolver.allowed_actors
    end
  end
end
