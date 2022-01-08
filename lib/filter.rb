# frozen_string_literal: true

class Filter
  OperatorValueInvalid = Class.new(StandardError)
  UnknownFilter = Class.new(StandardError)

  class << self
    attr_accessor :table

    def apply(relation, filters)
      base = new(relation)
      filters.each do |f|
        base = base.filter(f[:field], f[:op], f[:value])
      end

      base.relation
    end

    def default_table(table)
      @table = table
    end

    def filter(field, table: @table, join: nil, preprocess: nil, column: nil, &block)
      filters[field] = { table:, column:, join:, preprocess:, process: block }
    end

    def filters
      @filters ||= {}
    end
  end

  attr_accessor :relation

  def initialize(relation)
    @relation = relation
  end

  def filter(field, operator, value)
    value = cast_value(operator, value)

    config = self.class.filters[field]
    raise UnknownFilter, "Cannot filter on #{field.inspect}" unless config

    rel = config[:preprocess].call(@relation) if config[:preprocess]
    rel ||= @relation

    rel = rel.joins(config[:join]) if config[:join]
    rel =
      if config[:process]
        config[:process].call(rel, operator, value)
      else
        column = config[:column] || self.class.table[field.to_sym]
        rel.where(column.public_send(operator, value))
      end

    spawn(rel)
  end

  protected

  def spawn(relation)
    self.class.new(relation)
  end

  def cast_value(operator, value)
    case operator
    when :between
      case value
      when Array then (value.first..value.last)
      when Hash then (value[:from]..value[:to])
      else
        raise OperatorValueInvalid, "Cannot convert #{value.inspect} to range"
      end
    when :matches
      "%#{value}%"
    else
      value
    end
  end
end
