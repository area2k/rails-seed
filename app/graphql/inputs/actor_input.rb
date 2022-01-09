# frozen_string_literal: true

module Inputs
  class ActorInput < GraphQL::Schema::InputObject
    description 'Represents an actor'

    argument :id, ID, required: true
    argument :kind, Enums::ActorKindEnum, required: true
  end
end
