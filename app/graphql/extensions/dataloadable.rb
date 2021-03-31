# frozen_string_literal: true

module Extensions
  class Dataloadable < GraphQL::Schema::FieldExtension
    def apply
      if options[:association]
        model_class = options.fetch(:model, Object.const_get(field.owner.graphql_name))
        reflection = model_class.reflect_on_association(options[:association].to_sym)
        raise ArgumentError, "Unknown association :#{options[:association]} on #{model_class}" unless reflection

        options[:source] = build_source_from_reflection(reflection)
      else
        options[:source] = [options[:source], *options[:args]]
      end
    end

    def after_resolve(value:, context:, **)
      loaded = context.dataloader.with(*options[:source]).load(value)
      return loaded unless loaded.nil?

      options[:source][0] == Sources::RecordSource ? nil : []
    end

    private

    def build_source_from_reflection(reflection)
      case reflection
      when ActiveRecord::Reflection::HasManyReflection
        scope = build_has_many_scope(reflection)
        key = reflection.foreign_key

        [Sources::RelationSource, scope, key]
      when ActiveRecord::Reflection::ThroughReflection
        scope = build_through_scope(reflection)
        key = "#{reflection.through_reflection.table_name}.#{reflection.through_reflection.foreign_key}"

        [Sources::ThroughSource, scope, reflection.source_reflection.active_record, reflection.through_reflection.foreign_key]
      when ActiveRecord::Reflection::BelongsToReflection
        scope = build_belongs_to_scope(reflection)
        key = reflection.active_record_primary_key

        [Sources::RecordSource, scope, key]
      end
    end

    def build_belongs_to_scope(reflection)
      reflection.compute_class(reflection.class_name)
    end

    def build_has_many_scope(reflection)
      scope = reflection.compute_class(reflection.class_name).all
      scope = scope._exec_scope(&reflection.scope) if reflection.scope

      scope
    end

    def build_through_scope(reflection)
      model = reflection.active_record
      target_model = reflection.compute_class(reflection.class_name)
      through_model = reflection.source_reflection.active_record

      join = target_model.table.join(through_model.table)
      join = join.on(target_model.table[:id].eq(through_model.table[reflection.foreign_key.to_sym]))

      select = target_model.table.project(target_model.table[Arel.star])
      select = select.project(through_model.table[reflection.through_reflection.foreign_key.to_sym])

      target_model.joins(join.join_sources).select(select.projections)
    end
  end
end
