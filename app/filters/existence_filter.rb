# frozen_string_literal: true

class ExistenceFilter
  class << self
    def apply(filter:, value:)
      op = value ? :not_eq : :eq

      filter[:column].send(op, nil)
    end
  end
end
