# frozen_string_literal: true

module Inputs
  module Filters
    class IntCompareFilterInput < Inputs::BaseInput
      description 'Tests an operation against a static value'

      argument :op, Enums::CompareOperatorEnum, required: true
      argument :value, Int, required: true
    end
  end
end
