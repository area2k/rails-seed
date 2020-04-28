# frozen_string_literal: true

module Extensions
  class Sorting < GraphQL::Schema::FieldExtension
    def apply
      dir = options.fetch(:direction, 'ASC')

      field.argument :sort_by, String, required: false, default_value: options[:by]
      field.argument :sort_dir, Enums::SortDirectionEnum, required: false, default_value: dir
    end

    def after_resolve(arguments:, value:, **)
      return resolve_page(value, args: arguments) if page?(value)

      resolve_query(value, args: arguments)
    end

    private

    def page?(value)
      value.is_a?(Hash) && value.key?(:page_info)
    end

    def resolve_page(value, args:)
      { **value, items: resolve_query(value[:items], args: args) }
    end

    def resolve_query(value, args:)
      # REVIEW: this will break in Rails 6.1
      value.order("#{args[:sort_by]} #{args[:sort_dir]}")
    end
  end
end
