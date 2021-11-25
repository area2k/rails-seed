# frozen_string_literal: true

module Mutations
  module_function

  def make_problem_type(mutation_name, &block)
    lower_name = mutation_name.camelize(:lower)

    enum_class = Class.new(Enums::BaseEnum) do
      graphql_name "#{mutation_name}ProblemCode"
      description "Problem code for the #{lower_name} mutation"

      class_eval(&block)
    end

    Class.new(Types::BaseObject) do
      graphql_name "#{mutation_name}Problem"
      description "Represents a problem with the #{lower_name} mutation"

      implements Interfaces::Problem

      field :code, enum_class, null: false
    end
  end

  class Problem < StandardError
    attr_accessor :code, :message, :path

    def initialize(code, message: nil, path: [])
      @code = code
      @message = message || code.to_s.humanize
      @path = path

      super(message)
    end

    def to_s
      "Problem(#{code})"
    end
  end
end
