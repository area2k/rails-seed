# frozen_string_literal: true

class QueriesGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  class_option :skip_pagination, type: :boolean, desc: 'Skip pagination typing and extension'
  class_option :skip_filters, type: :boolean, desc: 'Skip adding `filters` argument and extension'

  def generate_files
    template 'single_query.erb', "app/graphql/queries/#{file_name}_query.rb"
    template 'collection_query.erb', "app/graphql/queries/#{file_name.pluralize}_query.rb"
  end

  private

  def collection_type_name
    base_type = "Types::#{class_name}Type"

    paginated? ? "#{base_type}.paginated" : "[#{base_type}]"
  end

  def filtered?
    !options[:skip_filters].present?
  end

  def human_class_name
    class_name.underscore.tr('_', ' ')
  end

  def model
    @model ||= class_name.constantize
  end

  def paginated?
    !options[:skip_pagination].present?
  end

  def variable_name
    class_name.underscore
  end
end
