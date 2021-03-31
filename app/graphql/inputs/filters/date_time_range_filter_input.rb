# frozen_string_literal: true

module Inputs
  module Filters
    class DateTimeRangeFilterInput < Inputs::BaseInput
      description 'Tests inclusion between a given inclusive range'

      argument :from, GraphQL::Types::ISO8601DateTime, required: true
      argument :inverse, Boolean, required: false, default_value: false,
        description: 'Treats operation as exclusion as opposed to inclusion'
      argument :to, GraphQL::Types::ISO8601DateTime, required: true
    end
  end
end
