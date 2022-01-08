# frozen_string_literal: true

module Extensions
  class Sortable < GraphQL::Schema::FieldExtension
    def apply
      field.argument :reverse, GraphQL::Types::Boolean, required: false,
        default_value: options.fetch(:default_reverse, false)
      field.argument :sort_key, options.fetch(:with), required: false,
        default_value: options.fetch(:default_value)
    end

    def resolve(object:, arguments:, **)
      clean_args = arguments.dup
      reverse = clean_args.delete(:reverse)
      sort_key = clean_args.delete(:sort_key)

      yield(object, clean_args, { reverse:, sort_key: })
    end

    def after_resolve(value:, memo:, **)
      reverse, sort_key = memo.values_at(:reverse, :sort_key)
      value.reorder(sort_key => reverse ? :desc : :asc)
    end
  end
end
