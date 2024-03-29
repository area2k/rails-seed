# frozen_string_literal: true

module Extensions
  class Pagination < GraphQL::Schema::FieldExtension
    def apply
      field.paginated = true
      field.extras << :lookahead

      per_page = options.fetch(:per_page, 25)

      field.argument :page, Scalars::PositiveInt, required: false, default_value: 1
      field.argument :per_page, Scalars::PositiveInt, required: false, default_value: per_page
    end

    def resolve(object:, arguments:, **)
      clean_args = arguments.dup
      page = clean_args.delete(:page)
      per_page = clean_args.delete(:per_page)

      yield(object, clean_args, { page:, per_page: })
    end

    def after_resolve(value:, arguments:, memo:, **)
      lookahead = arguments[:lookahead]
      page, per_page = memo.values_at(:page, :per_page)

      result = { items: resolve_items(value, page:, per_page:) }
      result[:page_info] = resolve_page_info(value, per_page:) if lookahead.selects?(:page_info)

      result
    end

    private

    def resolve_items(value, page:, per_page:)
      value.limit(per_page).offset((page - 1) * per_page)
    end

    def resolve_page_info(value, per_page:)
      total_items = value.unscope(:select).count
      total_pages = (total_items / per_page.to_f).ceil

      { total_items:, total_pages: }
    end
  end
end
