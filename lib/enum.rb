# frozen_string_literal: true

class Enum
  class << self
    def members
      @members ||= constants.each_with_object({}) do |elem, memo|
        memo[elem] = const_get(elem)
      end
    end
  end
end
