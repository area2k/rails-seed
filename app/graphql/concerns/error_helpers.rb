# frozen_string_literal: true

module ErrorHelpers
  def error!(code, message: nil, **kwargs)
    extensions = { **kwargs, code: }
    error_message = message || code.to_s.humanize

    raise GraphQL::ExecutionError.new(error_message, extensions:)
  end
end
