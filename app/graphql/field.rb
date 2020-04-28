# frozen_string_literal: true

class Field < GraphQL::Schema::Field
  prepend GraphQLPreload
end
