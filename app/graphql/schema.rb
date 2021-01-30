# frozen_string_literal: true

class Schema < GraphQL::Schema
  use GraphQL::Schema::Timeout, max_seconds: 5
  use GraphQL::Dataloader

  query_analyzer Analyzers::NoPaginationNesting

  query Types::QueryType
  mutation Types::MutationType
end
