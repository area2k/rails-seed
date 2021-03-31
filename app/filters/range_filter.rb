# frozen_string_literal: true

class RangeFilter
  class << self
    def apply(filter:, value:)
      from = value.fetch(:from)
      to = value.fetch(:to)
      inverse = value.fetch(:inverse, false)
      op = inverse ? :not_between : :between

      filter[:column].send(op, (from..to))
    end
  end
end
