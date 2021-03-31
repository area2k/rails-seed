# frozen_string_literal: true

class MembershipFilter
  class << self
    def apply(filter:, value:)
      val = value.fetch(:value)
      inverse = value.fetch(:inverse, false)
      op = inverse ? :not_in : :in

      val.any? ? filter[:column].send(op, val) : Arel::Nodes::False.new
    end
  end
end
