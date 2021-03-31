# frozen_string_literal: true

class EqualityFilter
  class << self
    def apply(filter:, value:)
      val = value.fetch(:value)
      inverse = value.fetch(:inverse, false)
      op = inverse ? :not_eq : :eq

      filter[:column].send(op, val)
    end
  end
end
