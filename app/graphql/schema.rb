# frozen_string_literal: true

require 'graphql_preload'

class Schema < GraphQL::Schema
  use GraphQL::Execution::Interpreter
  use GraphQL::Analysis::AST
  use GraphQL::Batch

  query_analyzer Analyzers::NoPaginationNesting

  query Types::QueryType
  mutation Types::MutationType if Types::MutationType.fields.any?

  middleware(GraphQL::Schema::TimeoutMiddleware.new(max_seconds: 5) do |_err, query|
    Rails.logger.error "GraphQL Timeout: #{query.query_string}"
  end)
end
