# frozen_string_literal: true

class Field < GraphQL::Schema::Field
  attr_accessor :allowed_actors, :paginated

  def initialize(*args, paginated: false, allow_actors: nil, **kwargs, &block)
    super(*args, **kwargs, &block)

    @paginated = paginated
    @allowed_actors = allow_actors.nil? ? nil : Array(allow_actors)
  end

  def accessible?(...)
    return super unless @allowed_actors.present?

    super && actor_allowed?(...)
  end

  # FIXME: this code causes the field to throw non-null errors
  # def authorized?(object, args, context)
  #   return super unless @allowed_actors.present?

  #   allowed = super && actor_allowed?(context)
  #   unless allowed
  #     raise Errors::BaseError.new(message: 'Not allowed', code: :AUTHORIZATION_FAILED)
  #   end
  # end

  def visible?(...)
    return super unless @allowed_actors.present?

    super && actor_allowed?(...)
  end

  private

  def actor_allowed?(context)
    context[:authenticated?] && context[:auth].actor_is?(*@allowed_actors)
  end
end
