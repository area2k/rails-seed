# frozen_string_literal: true

require 'active_support/concern'

module Searchable
  extend ActiveSupport::Concern

  included do
    class_attribute :searchable_columns

    scope :search, ->(query) { where(search_query("%#{query}%")) }
  end

  class_methods do
    def search_query(query)
      columns = searchable_columns.dup
      initial = table[columns.shift].matches(query)

      columns.reduce(initial) do |memo, element|
        memo.or(table[element].matches(query))
      end
    end

    def searchable(on:)
      self.searchable_columns = Array(on)
    end
  end
end
