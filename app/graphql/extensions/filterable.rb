# frozen_string_literal: true

module Extensions
  class Filterable < GraphQL::Schema::FieldExtension
    def apply
      filter_input_class = options.fetch(:input) do
        Inputs::Filters.const_get(options[:with].to_s)
      end

      field.argument :filters, [filter_input_class], required: false
    end

    def resolve(object:, arguments:, **)
      clean_args = arguments.dup
      filters = clean_args.delete(:filters)

      yield(object, clean_args, { filters: filters })
    end

    def after_resolve(value:, memo:, **)
      options[:with].apply(value, memo.fetch(:filters, []))
    end
  end
end
