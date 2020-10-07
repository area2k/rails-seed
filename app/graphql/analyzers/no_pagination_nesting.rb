# frozen_string_literal: true

module Analyzers
  class NoPaginationNesting < GraphQL::Analysis::AST::Analyzer
    def initialize(query_or_multiplex)
      super

      @max_nesting = 0
      @current_nesting = 0
    end

    def analyze?
      !introspection?
    end

    def on_enter_field(node, parent, visitor)
      return if visitor.skipping? || visitor.visiting_fragment_definition?

      field = visitor.field_definition
      return unless field.respond_to?(:paginated) && field.paginated

      @current_nesting += 1
    end

    def on_leave_field(node, parent, visitor)
      return if visitor.skipping? || visitor.visiting_fragment_definition?

      @max_nesting = @current_nesting if @max_nesting < @current_nesting

      field = visitor.field_definition
      @current_nesting -= 1 if field.respond_to?(:paginated) && field.paginated
    end

    def result
      raise GraphQL::AnalysisError.new('Schema does not allow nested paginated resources') if @max_nesting > 1
    end

    private

    def introspection?
      selections = subject.lookahead.selections

      selections.size == 1 && selections.first.name == :__schema
    end
  end
end
