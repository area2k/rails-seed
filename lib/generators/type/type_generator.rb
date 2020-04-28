# frozen_string_literal: true

class TypeGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def generate_files
    template 'type.erb', "app/graphql/types/#{file_name}_type.rb"
  end

  private

  def associations
    @associations ||= begin
      model.reflect_on_all_associations.map do |assoc|
        class_name = assoc.options.fetch(:class_name, assoc.name).to_s.classify
        list = assoc.is_a?(ActiveRecord::Reflection::HasManyReflection)

        { name: assoc.name,
          type: list ? "[#{class_name}Type]" : "#{class_name}Type",
          null: !list }
      end
    end
  end

  def db_columns
    model.columns_hash.each_with_object({}) do |(k, v), acc|
      next if k.end_with?('_id') || %w[created_at updated_at].include?(k)

      acc[k] = { type: v.sql_type_metadata.type, null: v.null }
    end
  end

  def model
    @model ||= class_name.constantize
  end

  def to_scalar(name, type)
    case type
    when :integer then name == 'id' ? 'ID' : 'Int'
    when :boolean then 'Boolean'
    when :date then 'GraphQL::Types::ISO8601Date'
    when :datetime then 'GraphQL::Types::ISO8601DateTime'
    else 'String'
    end
  end
end
