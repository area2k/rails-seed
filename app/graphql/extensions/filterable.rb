# frozen_string_literal: true

module Extensions
  class Filterable < GraphQL::Schema::FieldExtension
    def apply
      filter_input_class = options.fetch(:input) do
        Inputs::Filters.const_get(options[:with].to_s)
      end

      field.argument :filters, [filter_input_class], required: false
    end

    def after_resolve(arguments:, value:, **)
      options[:with].apply(value, arguments.fetch(:filters, []))
    end
  end
end
