# frozen_string_literal: true

class BaseMonad
  include Dry::Monads[:do, :maybe, :result]

  def find(model, **query)
    Maybe(model.find_by(**query))
  end
end
