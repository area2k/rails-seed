# frozen_string_literal: true

class Schema < GraphQL::Schema
  use GraphQL::Schema::Timeout, max_seconds: 5
  use GraphQL::Dataloader

  query_analyzer Analyzers::NoPaginationNesting

  query Types::QueryType
  mutation Types::MutationType

  rescue_from(Mutations::Problem) do |err|
    { problem: { code: err.code, message: err.message, path: err.path } }
  end

  def self.resolve_type(object, _context)
    if object.is_a?(ApplicationRecord)
      Types.const_get("#{object.class}Type")
    else
      super
    end
  end

  def self.unauthorized_object(error)
    msg = "Unauthorized to view field #{error.type.graphql_name}.#{error.field.graphql_name}"
    raise GraphQL::ExecutionError.new(msg, extensions: { code: 'AUTHORIZATION_FAILED' })
  end
end
