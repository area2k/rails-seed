# frozen_string_literal: true

module Interfaces
  module HasTimestamps
    include BaseInterface

    description 'An object with creation and update timestamps'

    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
