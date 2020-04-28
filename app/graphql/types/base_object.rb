# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    include Finders

    field_class Field
  end
end
