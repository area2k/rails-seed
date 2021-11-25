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
        column: parse_column(column || name),
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

      join_on = on.is_a?(Symbol) ? base_table[on].eq(@table[:id]) : on
      @join_sources << base_table.join(table, with).on(join_on).join_sources

      yield.tap do
        @join_sources.pop
        @table = base_table
      end
    end

    def on(table)
      @table = table
      yield.tap { @table = nil }
    end

    def search_nodes(*models)
      nodes = models.map(&:search_node)
      Arel::Nodes::ConcatWs.new(Arel::Nodes::SqlLiteral.new('" "'), *nodes)
    end

    private

    def parse_column(column)
      case column
      when Symbol then @table[column]
      when String then @table[column.to_sym]
      when Arel::Nodes::Node then column
      else
        raise ArgumentError "unknown column type: #{column.inspect}"
      end
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

    filters.each do |name, value|
      raise UnknownFilter, "Unknown filter: `#{name}`" unless self.class.filters.key?(name)

      filter = self.class.filters[name]
      conditional = filter[:resolver].apply(filter: filter, value: value)
      join_sources = filter[:join_sources]

      result[:conditions] << conditional if conditional
      result[:join_sources].concat(join_sources) if join_sources
    end

    [result[:conditions].reduce(@disjunctive ? :or : :and), result[:join_sources].uniq]
  end
end
