# frozen_string_literal: true

module Scalars
  class Void < BaseScalar
    description 'A nil value'

    def self.coerce_input(_value, _context)
      nil
    end

    def self.coerce_result(_value, _context)
      nil
    end
  end
end
