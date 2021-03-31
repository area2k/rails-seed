# frozen_string_literal: true

class CompareFilter
  class << self
    def apply(filter:, value:)
      op = value.fetch(:op)
      val = value.fetch(:value)

      filter[:column].send(op, val)
    end
  end
end
