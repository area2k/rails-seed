# frozen_string_literal: true

module Mutations
  class Problem < StandardError
    attr_accessor :code, :message, :path

    def initialize(code, message: nil, path: [])
      @code = code
      @message = message || code.to_s.humanize
      @path = path

      super(message)
    end

    def to_s
      "Problem(#{code})"
    end
  end
end
