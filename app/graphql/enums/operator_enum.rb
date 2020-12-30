# frozen_string_literal: true

module Enums
  class OperatorEnum < BaseEnum
    description 'Filter operators'

    value 'LT', 'Less-than', value: :lt
    value 'LTEQ', 'Less-than or equal', value: :lteq
    value 'GT', 'Greater-than', value: :gt
    value 'GTEQ', 'Greater-than or equal', value: :gteq
    value 'EQ', 'Exactly equal', value: :eq
    value 'NOT', 'Not-equal', value: :not_eq
    value 'IN', 'Equal to any value', value: :in
    value 'NIN', 'Not-equal to any value', value: :not_in
    value 'BTWN', 'Between a range of values', value: :between
    value 'LIKE', 'Fuzzy-match', value: :matches
  end
end
