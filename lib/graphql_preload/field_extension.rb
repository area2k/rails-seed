# frozen_string_literal: true

module GraphQLPreload
  class FieldExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, arguments:, context:)
      associations = options[:preload]
      scope = options[:scope]
      target = object.object

      scope = resolve_scope(scope, object, arguments, context) if scope

      preload(target, associations, scope).then do
        yield(object, arguments)
      end
    end

    private

    def preload(object, associations, scope)
      case associations
      when Symbol then preload_single(object, associations, scope)
      when String then preload_single(object, associations.to_sym, scope)
      when Array, Hash then preload_many(object, Array.wrap(associations), scope)
      end
    end

    def preload_many(object, associations, scope)
      wrap_in_promises do
        associations.each_with_object([]) do |association, promises|
          case association
          when Symbol
            promises << preload_single(object, association, scope)
          when Array
            association.each { |sub| promises << preload(object, sub, scope) }
          when Hash
            association.each do |sub, nested|
              promises << preload_single(object, sub, scope).then do |records|
                preload_nested(records, nested)
              end
            end
          end
        end
      end
    end

    def preload_nested(records, nested)
      # NOTE: handle loaders that may not return ActiveRecord Relations
      case records
      when ActiveRecord::Base then preload(records, nested, nil)
      else
        wrap_in_promises do
          Array.wrap(records).map { |record| preload(record, nested, nil) }
        end
      end
    end

    def preload_single(object, association, scope)
      symbol_check!(association)

      loader_type = object.is_a?(ActiveRecord::Base) ? RecordLoader : EntityLoader

      loader = loader_type.for(object.class, association, scope.try(:to_sql))
      loader.scope = scope
      loader.load(object)
    end

    def resolve_scope(preload_scope, object, arguments, context)
      if preload_scope.respond_to?(:call)
        preload_scope.call(object: object, arguments: arguments, context: context)
      elsif object.respond_to?(preload_scope.to_sym)
        object.public_send(preload_scope.to_sym, **arguments)
      else
        object.object.public_send(preload_scope.to_sym, **arguments)
      end
    end

    def symbol_check!(input)
      raise TypeError, "Expected #{input} to be a Symbol" unless input.is_a?(Symbol)
    end

    def wrap_in_promises
      Promise.all(yield)
    end
  end
end
