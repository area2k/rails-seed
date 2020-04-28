# frozen_string_literal: true

module GraphQLPreload
  class RecordLoader < BaseLoader
    private

    def association_loaded?(record)
      record.association(@association).loaded?
    end

    def preload_association(records)
      ActiveRecord::Associations::Preloader.new.preload(records, @association, preload_scope)
    end

    def read_association(record)
      record.public_send(@association)
    end
  end
end
