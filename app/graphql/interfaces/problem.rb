# frozen_string_literal: true

module Interfaces
  module Problem
    include BaseInterface

    description 'An object that represents a mutation problem'

    field :message, String, null: false,
      description: 'A human-readable description of the problem'
    field :path, [String], null: false,
      description: 'A path to the argument that caused the problem, may be empty'
  end
end
