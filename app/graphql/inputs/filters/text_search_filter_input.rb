# frozen_string_literal: true

module Inputs
  module Filters
    class TextSearchFilterInput < Inputs::BaseInput
      description 'Tests field for inclusion of a given substring'

      argument :inverse, Boolean, required: false, default_value: false,
        description: 'Treats operation as exclusion as opposed to inclusion'
      argument :mode, Enums::TextSearchModeEnum, required: false, default_value: :contains,
        description: 'Sets the testing mode'
      argument :value, String, required: true
    end
  end
end
