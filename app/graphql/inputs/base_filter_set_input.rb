# frozen_string_literal: true

module Inputs
  class BaseFilterSetInput < BaseInput
    argument :apply_disjunctively, Boolean, required: false, default_value: false,
      description: 'Combines all filters disjunctively (logical OR)'

    def prepare
      to_h
    end
  end
end
