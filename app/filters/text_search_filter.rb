# frozen_string_literal: true

class TextSearchFilter
  class << self
    def apply(filter:, value:)
      val = value.fetch(:value)
      inverse = value.fetch(:inverse, false)
      op = inverse ? :does_not_match : :matches

      val = case value.fetch(:mode, :contains)
            when :contains then "%#{val}%"
            when :prefix then "#{val}%"
            when :suffix then "%#{val}"
            end

      # NB: Lowercasing everything is not needed because of how MySQL collate
      #   is configured currently. If that changes, so shall this need to as well
      filter[:column].send(op, val)
    end
  end
end
