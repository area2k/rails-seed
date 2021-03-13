# frozen_string_literal: true

module Sources
  class RelationSource < BaseSource
    def initialize(base_relation, query_by = :id)
      super

      @base_relation = base_relation
      @query_by = query_by
    end

    def fetch(ids)
      records = @base_relation.where(@query_by => ids)
      records_by_id = group_items(records) { |r| r.public_send(@query_by) }

      ids.map { |id| records_by_id.fetch(id, nil) }
    end
  end
end
