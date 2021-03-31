# frozen_string_literal: true

module Inputs
  module Filters
    class DateTimeCompareFilterInput < Inputs::BaseInput
      description 'Tests an operation against a static value'

      argument :op, Enums::CompareOperatorEnum, required: true
      argument :value, GraphQL::Types::ISO8601DateTime, required: true
    end
  end
end
