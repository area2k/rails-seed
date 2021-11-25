# frozen_string_literal: true

class Field < GraphQL::Schema::Field
  attr_accessor :allowed_actors, :paginated

  def initialize(*args, allow_actors: nil, **kwargs, &block)
    super(*args, connection_extension: nil, **kwargs, &block)

    @paginated = connection?
    @allowed_actors = allow_actors.nil? ? nil : Array(allow_actors)

    # NOTE: added last in stack to allow manipulation of underlying relation
    extension(self.class.connection_extension) if connection? && !kwargs.key?(:connection_extension)
  end

  def authorized?(_object, _args, context)
    return super unless @allowed_actors.present?

    super && actor_allowed?(context)
  end

  private

  def actor_allowed?(context)
    context[:authenticated?] && context[:auth].actor_is?(*@allowed_actors)
  end
end
