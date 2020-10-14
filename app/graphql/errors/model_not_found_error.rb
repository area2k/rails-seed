# frozen_string_literal: true

module Errors
  class ModelNotFoundError < BaseError
    def initialize(model:, query:)
      super(message: "Cannot find #{model}",
            code: :MODEL_NOT_FOUND,
            model: model.base_class_name,
            query: query)
    end
  end
end
