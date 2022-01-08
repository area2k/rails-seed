# frozen_string_literal: true

class Resolver < GraphQL::Schema::Resolver
  include ArgumentLoader
  include AuthHelpers
  include ErrorHelpers
  include MonadicResolver

  protected

  def with_void_return(&)
    nil.tap(&)
  end
end
