# frozen_string_literal: true

module Inputs
  module Filters
    class IntRangeFilterInput < Inputs::BaseInput
      description 'Tests inclusion between a given inclusive range'

      argument :from, Int, required: true
      argument :inverse, Boolean, required: false, default_value: false,
        description: 'Treats operation as exclusion as opposed to inclusion'
      argument :to, Int, required: true
    end
  end
end
