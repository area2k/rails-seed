# frozen_string_literal: true

require 'active_support/concern'

module Searchable
  extend ActiveSupport::Concern

  included do
    class_attribute :searchable_columns

    scope :search, ->(query) { where(search_node.matches("%#{query}%")) }
  end

  class_methods do
    def search_column
      @search_column ||= search_node.as('search')
    end

    def search_node
      @search_node ||= generate_search_node
    end

    def searchable_nodes
      @searchable_nodes ||= searchable_columns.map { |el| table[el] }
    end

    def searchable(on:)
      self.searchable_columns = Array(on)
    end

    private

    def generate_search_node
      return searchable_nodes.first if searchable_nodes.size == 1

      Arel::Nodes::ConcatWs.new(Arel::SPACE, *searchable_nodes)
    end
  end
end
