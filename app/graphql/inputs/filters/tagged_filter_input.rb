# frozen_string_literal: true

module Inputs
  module Filters
    class TaggedFilterInput < Inputs::BaseInput
      description 'Tests model for inclusion of ALL given tags'

      argument :inverse, Boolean, required: false, default_value: false,
        description: 'Treats operation as exclusion as opposed to inclusion'
      argument :tag_ids, [ID], required: true, as: :value
    end
  end
end
