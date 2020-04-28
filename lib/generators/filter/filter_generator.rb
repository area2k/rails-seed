# frozen_string_literal: true

class FilterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def generate_files
    template 'filter.erb', "app/filters/#{file_name}_filter.rb"
    template 'enum.erb', "app/graphql/enums/#{file_name}_field_enum.rb"
    template 'input.erb', "app/graphql/inputs/filters/#{file_name}_filter.rb"
  end

  private

  def db_columns
    model.columns_hash.keys
  end

  def model
    @model ||= class_name.constantize
  end
end
