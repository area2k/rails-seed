# frozen_string_literal: true

module Inputs
  module Filters
    class IDMembershipFilterInput < Inputs::BaseInput
      description 'Tests field for inclusion in a list'

      argument :inverse, Boolean, required: false, default_value: false,
        description: 'Treats operation as exclusion as opposed to inclusion'
      argument :value, [ID], required: true
    end
  end
end
