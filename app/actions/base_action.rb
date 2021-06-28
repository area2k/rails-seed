# frozen_string_literal: true

class BaseAction
  include Dry::Monads[:maybe, :result, :do]

  def find(model, **query)
    Maybe(model.find_by(**query))
  end

  def find!(...)
    find(...).to_result(:model_not_found)
  end

  class << self
    def call(...)
      new(...).call
    end
  end
end
