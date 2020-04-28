# frozen_string_literal: true

module Timestamps
  extend ActiveSupport::Concern

  included do
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
