# frozen_string_literal: true

module Extensions
  class Sorting < GraphQL::Schema::FieldExtension
    def apply
      dir = options.fetch(:direction, 'ASC')

      field.argument :sort_by, String, required: false, default_value: options[:by]
      field.argument :sort_dir, Enums::SortDirectionEnum, required: false, default_value: dir
    end

    def resolve(object:, arguments:, **)
      clean_args = arguments.dup
      sort_by = clean_args.delete(:sort_by)
      sort_dir = clean_args.delete(:sort_dir)

      yield(object, clean_args, { by: sort_by, dir: sort_dir })
    end

    def after_resolve(value:, memo:, **)
      return resolve_page(value, by: memo[:by], dir: memo[:dir]) if page?(value)

      resolve_query(value, by: memo[:by], dir: memo[:dir])
    end

    private

    def page?(value)
      value.is_a?(Hash) && value.key?(:page_info)
    end

    def resolve_page(value, **kwargs)
      { **value, items: resolve_query(value[:items], **kwargs) }
    end

    def resolve_query(value, by:, dir:)
      value.order(by => dir)
    end
  end
end
