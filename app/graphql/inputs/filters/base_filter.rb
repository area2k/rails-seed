# frozen_string_literal: true

module Inputs
  module Filters
    class BaseFilter < BaseInput
      argument :op, Enums::OperatorEnum, required: true
      argument :value, GraphQL::Types::JSON, required: true

      def prepare
        to_h
      end
    end
  end
end
