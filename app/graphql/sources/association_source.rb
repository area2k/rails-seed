# frozen_string_literal: true

module Sources
  class AssociationSource < GraphQL::Dataloader::Source
    def initialize(_model_class, association_name)
      @association_name = association_name
    end

    def fetch(models)
      preload_associations(models)

      models.map do |model|
        model.public_send(@association_name)
      end
    end

    private

    def preload_associations(models)
      ActiveRecord::Associations::Preloader.new.preload(models, @association_name)
    end
  end
end
