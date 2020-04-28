# frozen_string_literal: true

module GraphQLPreload
  class BaseLoader < GraphQL::Batch::Loader
    attr_accessor :scope
    attr_reader :association, :target_class

    def cache_key(target)
      target.object_id
    end

    # NOTE: scope_as_sql is needed only for "namespacing" the loaders in GraphQL::Batch,
    #   so as to keep separate from other loaders with the same target class and
    #   association name, but different scope
    def initialize(target_class, association, _scope_as_sql)
      @target_class = target_class
      @association = association
    end

    def load(target)
      type_check!(target)

      return Promise.resolve(read_association(target)) if association_loaded?(target)

      super
    end

    def perform(targets)
      preload_association(targets)
      targets.each { |target| fulfill(target, read_association(target)) }
    end

    private

    def preload_scope
      return unless @scope

      @scope
    end

    def type_check!(object)
      return if object.is_a?(@target_class)

      raise TypeError, "Loader for #{@target_class} cannot load for #{object.class} objects"
    end
  end
end
