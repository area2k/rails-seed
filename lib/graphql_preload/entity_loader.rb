# frozen_string_literal: true

module GraphQLPreload
  class EntityLoader < BaseLoader
    private

    def association_loaded?(entity)
      entity.model.association(@association).loaded?
    end

    def preload_association(entities)
      records = entities.map(&:model)
      ActiveRecord::Associations::Preloader.new.preload(records, @association, preload_scope)
    end

    def read_association(entity)
      entity.model.public_send(@association)
    end
  end
end
