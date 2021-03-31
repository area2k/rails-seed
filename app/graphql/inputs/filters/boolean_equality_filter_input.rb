# frozen_string_literal: true

module Inputs
  module Filters
    class BooleanEqualityFilterInput < Inputs::BaseInput
      description 'Tests field for equality to a given value'

      argument :inverse, Boolean, required: false, default_value: false,
        description: 'Treats operation as inequality as opposed to equality'
      argument :value, Boolean, required: true
    end
  end
end
