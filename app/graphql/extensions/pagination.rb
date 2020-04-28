# frozen_string_literal: true

module Extensions
  class Pagination < GraphQL::Schema::FieldExtension
    def apply
      per_page = options.fetch(:per_page, 25)

      field.argument :page, Scalars::PositiveInt, required: false, default_value: 1
      field.argument :per_page, Scalars::PositiveInt, required: false, default_value: per_page
    end

    def after_resolve(arguments:, value:, **)
      page = arguments[:page]
      per_page = arguments[:per_page]

      total_items = value.unscope(:select).count
      total_pages = (total_items / per_page.to_f).ceil

      {
        items: value.limit(per_page).offset((page - 1) * per_page),
        page_info: {
          total_items: total_items,
          total_pages: total_pages
        }
      }
    end
  end
end
