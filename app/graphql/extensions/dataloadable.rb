# frozen_string_literal: true

module Extensions
  class Dataloadable < GraphQL::Schema::FieldExtension
    def apply
      if options[:association]
        model_class = Object.const_get(field.owner.graphql_name)
        reflection = model_class.reflect_on_association(options[:association])

        options[:source] = build_source_from_reflection(reflection)
      else
        options[:source] = [options[:source], *options[:args]]
      end
    end

    def after_resolve(value:, context:, **)
      loaded = context.dataloader.with(*options[:source]).load(value)
      return loaded unless loaded.nil?

      options[:source][0] == Sources::RelationSource ? [] : nil
    end

    private

    def build_source_from_reflection(reflection)
      target_model_class = reflection.compute_class(reflection.class_name)

      case reflection
      when ActiveRecord::Reflection::HasManyReflection
        target_scope = target_model_class.all
        target_scope = target_scope._exec_scope(&reflection.scope) if reflection.scope

        [Sources::RelationSource, target_scope, reflection.foreign_key.to_sym]
      when ActiveRecord::Reflection::BelongsToReflection
        [Sources::RecordSource, target_model_class, reflection.active_record_primary_key.to_sym]
      end
    end
  end
end
