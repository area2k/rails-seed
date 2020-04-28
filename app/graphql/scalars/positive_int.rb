# frozen_string_literal: true

module Scalars
  class PositiveInt < GraphQL::Types::Int
    description 'An Int with a value > 0'

    def self.coerce_input(value, _context)
      super

      value.tap { invalid!(value) unless value.positive? }
    end

    def self.invalid!(value)
      raise GraphQL::CoercionError, "#{value.inspect} is not a positive integer"
    end
  end
end
