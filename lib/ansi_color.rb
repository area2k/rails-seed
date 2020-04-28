# frozen_string_literal: true

module ANSIColor
  ESCAPE = "\e["
  RESET = '0m'
  CODES = {
    black: '30',
    red: '31',
    green: '32',
    yellow: '33',
    blue: '34',
    magenta: '35',
    cyan: '36'
  }.freeze

  CODES.each do |color, code|
    define_method(color) do |string, bold: false|
      attributes = bold ? "#{code};1" : code
      "#{ESCAPE}#{attributes}m#{string}#{ESCAPE}#{RESET}"
    end
  end
end
