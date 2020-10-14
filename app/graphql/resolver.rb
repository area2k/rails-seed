# frozen_string_literal: true

class Resolver < GraphQL::Schema::Resolver
  include AuthHelpers
  include CustomArgumentLoader
  include ErrorHelpers
  include Finders

  def authorized?(**args)
    permitted?(**args).tap do |permitted|
      error! message: 'Not permitted', code: :AUTHORIZATION_FAILED
    end
  end

  def permitted?(**kwargs)
    true
  end

  def prescreen?(**kwargs)
    true
  end

  def ready?(**args)
    prescreen?(**args).tap do |allowed|
      error! message: 'Not allowed', code: :AUTHORIZATION_FAILED
    end
  end

  protected

  def with_void_return
    nil.tap { yield }
  end
end
