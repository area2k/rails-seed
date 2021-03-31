# frozen_string_literal: true

module Inputs
  module Filters
    class IDEqualityFilterInput < Inputs::BaseInput
      description 'Tests field for equality to a given value'

      argument :inverse, Boolean, required: false, default_value: false,
        description: 'Treats operation as inequality as opposed to equality'
      argument :value, ID, required: true
    end
  end
end
