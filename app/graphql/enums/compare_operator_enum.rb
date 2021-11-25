# frozen_string_literal: true

module Enums
  class CompareOperatorEnum < BaseEnum
    description 'Represents a operator to compare two objects of the same type'

    value 'EQ', 'Exactly equal', value: :eq
    value 'NOT', 'Not-equal', value: :not_eq
    value 'LT', 'Less-than', value: :lt
    value 'LTEQ', 'Less-than or equal', value: :lteq
    value 'GT', 'Greater-than', value: :gt
    value 'GTEQ', 'Greater-than or equal', value: :gteq
  end
end
