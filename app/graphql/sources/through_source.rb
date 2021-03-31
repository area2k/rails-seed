# frozen_string_literal: true

module Sources
  class ThroughSource < BaseSource
    def initialize(base_relation, through_model, foreign_key)
      @base_relation = base_relation
      @through_model = through_model
      @foreign_key = foreign_key
    end

    def fetch(foreign_ids)
      records = @base_relation.where(@through_model.table[@foreign_key].in(foreign_ids))
      records_by_foreign_id = group_items(records) { |r| r.public_send(@foreign_key) }

      foreign_ids.map { |id| records_by_foreign_id.fetch(id, nil) }
    end
  end
end
