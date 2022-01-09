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

      def define_problems(field_name = :problem, &)
        problems = MutationProblems.new
        problems.instance_exec(&)

        type_class = generate_problem_type(problems)

        field field_name, type_class, null: true

        problems_class = Class.new do
          problems.each do |key, defn|
            const_set(key.to_s.upcase, Problem.new(defn[:code], path: defn[:path]).freeze)
          end
        end

        const_set('Problems', problems_class)
      end

      private

      def generate_problem_type(problem_definitions)
        mutation_name = name.demodulize
        lower_name = mutation_name.camelize(:lower)

        enum_class = Class.new(Enums::BaseEnum) do
          graphql_name "#{mutation_name}ProblemCode"
          description "Problem code for the #{lower_name} mutation"

          problem_definitions.each_value do |defn|
            value defn[:code], description: defn[:description]
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

    def request_attrs
      context[:request].slice(:client, :client_version, :ip, :user_agent)
    end

    def with_void_return(&)
      nil.tap(&)
    end
  end

  class MutationProblems
    attr_reader :values

    delegate :[], :each, :each_value, :fetch, to: :values

    def initialize
      @values = {}
    end

    def problem(key, description:, path: [], code: nil)
      code ||= key.to_s.upcase
      @values[key] = { description:, path:, code: }
    end
  end
end
