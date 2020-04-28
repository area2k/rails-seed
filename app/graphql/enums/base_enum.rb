# frozen_string_literal: true

module Enums
  class BaseEnum < GraphQL::Schema::Enum
    class << self
      def from_enum(enum_class)
        enum_class.members.each do |key, value|
          value key, value: value
        end
      end
    end
  end
end
