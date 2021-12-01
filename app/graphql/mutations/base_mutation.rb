# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    include ArgumentLoader
    include AuthHelpers
    include ErrorHelpers
    include MonadicResolver

    field_class Field

    null false

    class << self
      def default_graphql_name
        name.split('::').last
      end

      def define_problems(problem_definitions)
        type_class = generate_problem_type(problem_definitions)

        field :problem, type_class, null: true

        Class.new do
          problem_definitions.each do |key, defn|
            code = defn.fetch(:code, key.to_s)
            const_set(key, Problem.new(code, path: defn[:path]).freeze)
          end

          const_set 'Type', type_class
        end
      end

      private

      def generate_problem_type(problem_definitions)
        mutation_name = name.demodulize
        lower_name = mutation_name.camelize(:lower)

        enum_class = Class.new(Enums::BaseEnum) do
          graphql_name "#{mutation_name}ProblemCode"
          description "Problem code for the #{lower_name} mutation"

          problem_definitions.each do |code, defn|
            value code, description: defn[:description]
          end
        end

        Class.new(Types::BaseObject) do
          graphql_name "#{mutation_name}Problem"
          description "Represents a problem with the #{lower_name} mutation"

          implements Interfaces::Problem

          field :code, enum_class, null: false
        end
      end
    end

    protected

    def with_void_return(&block)
      nil.tap(&block)
    end
  end
end
