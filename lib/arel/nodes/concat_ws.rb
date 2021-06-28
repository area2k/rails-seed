# frozen_string_literal: true

module Arel
  module Nodes
    class ConcatWs < NamedFunction
      def initialize(*args)
        super('CONCAT_WS', args)
      end
    end
  end
end
