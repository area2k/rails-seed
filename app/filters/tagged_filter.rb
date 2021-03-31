# frozen_string_literal: true

class TaggedFilter
  NULL_LITERAL = Arel::Nodes::SqlLiteral.new('NULL').freeze

  class << self
    def apply(filter:, value:)
      val = value.fetch(:value)
      inverse = value.fetch(:inverse, false)
      model = arel_table_to_model(filter[:table])

      taggings = Tagging.table.join(Tag.table).on(Tagging.table[:tag_id].eq(Tag.table[:id]))
      taggings = taggings.where(Tagging.table[:target_type].eq(model.to_s))
      taggings = taggings.where(Tag.table[:id].in(val))
      taggings = taggings.project(NULL_LITERAL).group(:target_id)
      taggings = taggings.having(Tag.table[:id].count.eq(val.size))

      exists = Arel::Nodes::Exists.new(taggings)
      inverse ? exists.invert : exists
    end

    private

    def arel_table_to_model(table)
      table.instance_variable_get(:@klass)
    end
  end
end
