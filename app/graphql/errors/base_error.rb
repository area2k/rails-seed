# frozen_string_literal: true

module Errors
  class BaseError < GraphQL::ExecutionError
    def initialize(message: 'Something went wrong', code: 'GENERIC_ERROR', **kwargs)
      super(message, extensions: { code: code, **kwargs })
    end
  end
end
