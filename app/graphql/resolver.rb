# frozen_string_literal: true

class Resolver < GraphQL::Schema::Resolver
  include AuthHelpers
  include CustomArgumentLoader
  include ErrorHelpers
  include Finders

  protected

  def with_void_return(&block)
    nil.tap(&block)
  end
end
