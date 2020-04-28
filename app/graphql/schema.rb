# frozen_string_literal: true

require 'graphql_preload'

class Schema < GraphQL::Schema
  query Types::QueryType
  mutation Types::MutationType if Types::MutationType.fields.any?

  # use new ruby-graphql 1.9+ runtime
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST

  # use batching backend for graphql-preload
  use GraphQL::Batch

  # max_depth 10

  middleware(GraphQL::Schema::TimeoutMiddleware.new(max_seconds: 5) do |_err, query|
    Rails.logger.info "GraphQL Timeout: #{query.query_string}"
  end)
end
