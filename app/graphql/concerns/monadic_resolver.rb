# frozen_string_literal: true

module MonadicResolver
  extend ActiveSupport::Concern

  include Dry::Monads[:do, :maybe, :result]

  def monadic_find(model, **query)
    maybe_find(model, **query).to_result(:model_not_found)
  end

  def maybe_find(model, **query)
    Maybe(model.find_by(**query))
  end

  def resolve(**kwargs)
    result = monadic_resolve(**kwargs)

    case result
    when Success
      result.value!
    when Failure
      error = result.failure
      Rails.logger.error "#{error} on #{result.trace}"

      case error
      when Symbol
        error! message: error.to_s.humanize, code: error
      when Array
        error! message: error[1], code: error[0].to_s.upcase
      when StandardError
        error! message: error.message, code: error.class.name.underscore.upcase
      else
        error! message: 'Server error', code: :SERVER_ERROR
      end
    else
      raise "Result #{result.inspect} is not a monad"
    end
  end
end
