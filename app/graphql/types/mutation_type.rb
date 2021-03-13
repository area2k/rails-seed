# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    description 'The mutation root of this schema'
    graphql_name 'Mutation'

    (Mutations.constants - %i[BaseMutation]).each do |mutation_name|
      mutation = Mutations.const_get(mutation_name)
      field mutation_name.to_s.underscore, mutation: mutation, allow_actors: mutation.allowed_actors
    end
  end
end
