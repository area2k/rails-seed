# frozen_string_literal: true

module Sources
  class RecordSource < BaseSource
    def initialize(model_class, query_by = :id)
      super

      @model_class = model_class
      @query_by = query_by
    end

    def fetch(ids)
      records = @model_class.where(@query_by => ids)
      record_by_id = map_items(records) { |r| r.public_send(@query_by) }

      ids.map { |id| record_by_id.fetch(id, nil) }
    end
  end
end
