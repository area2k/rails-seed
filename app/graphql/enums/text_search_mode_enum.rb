# frozen_string_literal: true

module Enums
  class TextSearchModeEnum < BaseEnum
    description 'Represents a mode of searching text for a substring'

    value 'CONTAINS', 'String contains', value: :contains
    value 'PREFIX', 'String starts with', value: :prefix
    value 'SUFFIX', 'String ends with', value: :suffix
  end
end
