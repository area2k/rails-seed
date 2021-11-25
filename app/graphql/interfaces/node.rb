# frozen_string_literal: true

module Interfaces
  module Node
    include BaseInterface

    description 'An object with an ID'

    field :id, GraphQL::Types::ID, null: false

    def id
      object.uuid
    end
  end
end
