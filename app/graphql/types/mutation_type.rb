# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    description 'The mutation root of this schema'
    graphql_name 'Mutation'

    Mutations.constants.each do |name|
      mutation = Mutations.const_get(name)
      next unless mutation < Mutations::BaseMutation

      field name.to_s.underscore, mutation:, allow_actors: mutation.allowed_actors
    end
  end
end
