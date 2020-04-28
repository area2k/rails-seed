# frozen_string_literal: true

module UUID
  extend ActiveSupport::Concern

  included do
    field :id, GraphQL::Types::ID, null: false
  end

  def id
    object.uuid
  end
end
