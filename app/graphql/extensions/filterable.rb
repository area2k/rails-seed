# frozen_string_literal: true

module Extensions
  class Filterable < GraphQL::Schema::FieldExtension
    def apply
      input_class = options.fetch(:input) do
        Inputs.const_get("#{options.fetch(:with)}Input".demodulize)
      end

      field.argument :filters, input_class, required: false
    end

    def resolve(object:, arguments:, **)
      clean_args = arguments.dup
      filters = clean_args.delete(:filters)

      yield(object, clean_args, { filters: })
    end

    def after_resolve(value:, memo:, **)
      filters = memo[:filters]
      return value unless filters

      disjunctive = filters.delete(:apply_disjunctively) || false
      options.fetch(:with).apply(value, filters, disjunctive:)
    end
  end
end
