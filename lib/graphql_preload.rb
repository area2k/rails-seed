# frozen_string_literal: true

module GraphQLPreload
  def initialize(preload: nil, preload_scope: nil, **kwargs, &block)
    super(**kwargs, &block)

    @preload ||= preload.is_a?(TrueClass) ? @original_name : preload
    @preload_scope ||= preload_scope
    return unless @preload || @preload_scope

    extension(FieldExtension, preload: @preload, preload_scope: @preload_scope)
  end

  def preload(value)
    @preload = value.is_a?(TrueClass) ? @original_name : value
  end

  def preload_scope(value)
    @preload_scope = value
  end

  def to_graphql
    super.tap do |defn|
      defn.metadata[:preload] = @preload
      defn.metadata[:preload_scope] = @preload_scope
    end
  end
end
