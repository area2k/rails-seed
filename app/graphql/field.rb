# frozen_string_literal: true

class Field < GraphQL::Schema::Field
  attr_accessor :paginated

  def initialize(*args, paginated: false, **kwargs, &block)
    super(*args, **kwargs, &block)

    @paginated = paginated
  end
end
