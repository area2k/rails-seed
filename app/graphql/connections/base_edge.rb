# frozen_string_literal: true

module Connections
  class BaseEdge < GraphQL::Types::Relay::BaseEdge
    node_nullable false
  end
end
