# frozen_string_literal: true

module MonadicResolver
  include Dry::Monads[:maybe, :result]

  def monadic_find(model, **query)
    maybe_find(model, **query).to_result(:model_not_found)
  end

  def maybe_find(model, **query)
    Maybe(model.find_by(**query))
  end

  def resolve(...)
    result = monadic_resolve(...)

    case result
    when Success
      result.value!
    when Failure
      error = result.failure
      Rails.logger.error "#{error} on #{result.trace}"

      case error
      when Symbol
        { problem: { code: error.to_s.upcase, message: error.to_s.humanize, path: [] } }
      when Mutations::Problem
        { problem: { code: error.code, message: error.message, path: error.path } }
      else
        error! 'UNKNOWN_PROBLEM', message: 'Unknown problem occurred'
      end
    else
      raise "Result #{result.inspect} is not a monad"
    end
  end
end
