# frozen_string_literal: true

class BaseFilterSet
  UnknownFilter = Class.new(StandardError)

  class << self
    attr_reader :join_sources, :table

    def apply(relation, filters, disjunctive: false)
      new(relation, disjunctive: disjunctive).apply(filters)
    end

    def filter(name, resolver, column: nil, **args)
      filters[name.to_sym || column] = {
        table: @table,
        column: (column.is_a?(Symbol) ? @table[column] : column) || @table[name.to_sym],
        resolver: resolver,
        join_sources: @join_sources&.flatten,
        args: args
      }
    end

    def filters
      @filters ||= {}
    end

    def join(table, on:, with: Arel::Nodes::InnerJoin)
      base_table = @table
      raise 'A `join` block must be nested' unless base_table

      @table = table
      @join_sources ||= []
      @join_sources << base_table.join(table, with).on(on).join_sources

      yield.tap do
        @join_sources.pop
        @table = base_table
      end
    end

    def on(table)
      @table = table
      yield.tap { @table = nil }
    end
  end

  attr_reader :relation, :disjunctive

  def initialize(relation, disjunctive: false)
    @relation = relation
    @disjunctive = disjunctive
  end

  def apply(filters)
    conditions, joins = filters_to_arel(filters)

    @relation.joins(joins).where(conditions)
  end

  private

  def filters_to_arel(filters)
    result = Hash.new { |hash, key| hash[key] = [] }
    result = filters.each_with_object(result) do |(name, value), acc|
      raise UnknownFilter, "Unknown filter: `#{name}`" unless self.class.filters.key?(name)

      filter = self.class.filters[name]

      conditional = filter[:resolver].apply(filter: filter, value: value)
      join_sources = filter[:join_sources]

      acc[:conditions] << conditional if conditional
      acc[:join_sources].concat(join_sources) if join_sources
    end

    [result[:conditions].reduce(@disjunctive ? :or : :and), result[:join_sources].uniq]
  end
end
