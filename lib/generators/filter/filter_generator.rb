# frozen_string_literal: true

class FilterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def generate_files
    template 'filter_set.erb', "app/filter_sets/#{file_name}_filter_set.rb"
    template 'input.erb', "app/graphql/inputs/#{file_name}_filter_set_input.rb"
  end

  private

  def db_columns
    @db_columns ||= model.columns_hash
  end

  def db_column_names
    db_columns.keys
  end

  def filterable_associations
    model.reflect_on_all_associations.select do |r|
      r.is_a?(ActiveRecord::Reflection::BelongsToReflection)
    end
  end

  def filterable_column_names
    (db_column_names - %w[id created_at updated_at]).delete_if do |name|
      name.ends_with?('_id')
    end
  end

  def filters
    @filters ||= generate_filters
  end

  def generate_filters
    column_filters = filterable_column_names.each_with_object({}) do |elem, acc|
      column_data = db_columns[elem]
      resolver, input_type = column_to_filter_attributes(column_data.sql_type_metadata.type)

      acc[elem] = { resolver: resolver, input_type: input_type }
    end

    association_filters = filterable_associations.each_with_object({}) do |elem, acc|
      acc[elem.foreign_key] = {
        resolver: 'MembershipFilter', input_type: 'Filters::IDMembershipFilterInput',
        input_as: elem.plural_name
      }
    end

    { **column_filters, **association_filters }
  end

  def model
    @model ||= class_name.constantize
  end

  def column_to_filter_attributes(sql_type)
    case sql_type
    when :integer then %w[CompareFilter Filters::IntCompareFilterInput]
    when :date, :datetime then %w[CompareFilter Filters::DateTimeCompareFilterInput]
    when :boolean then %w[EqualityFilter Filters::BooleanEqualityFilterInput]
    else %w[TextSearchFilter String]
    end
  end
end
