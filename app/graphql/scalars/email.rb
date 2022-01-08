# frozen_string_literal: true

module Scalars
  class Email < BaseScalar
    description 'A properly formatted email address'

    REGEX = /\A(?:[\w+\-].?)+@[a-z\d\-]+(?:\.[a-z0-9]+)*\.[a-z0-9]+\z/i

    def self.coerce_input(value, _context)
      value.tap { invalid!(value) unless value =~ REGEX }
    end

    def self.invalid!(value)
      raise GraphQL::CoercionError, "#{value.inspect} is not a valid email"
    end
  end
end
