# frozen_string_literal: true

require_relative './ansi_color.rb'

module TaggedTimestampFormatter
  extend ANSIColor

  ERROR = 'ERROR'
  WARN = 'WARN'

  module_function

  def call(severity, time, _progname, message)
    "#{format_timestamp(time, severity)} #{tags_text}#{message}\n"
  end

  def format_timestamp(time, severity)
    stamp = "[#{time.utc.strftime('%Y-%m-%d %H:%M:%S.%L')}]"

    case severity
    when ERROR then red(stamp, bold: true)
    when WARN then yellow(stamp, bold: true)
    else black(stamp, bold: true)
    end
  end
end
