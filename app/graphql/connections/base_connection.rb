# frozen_string_literal: true

module Connections
  class BaseConnection < GraphQL::Types::Relay::BaseConnection
    edge_nullable false
    edges_nullable false
    node_nullable false
  end
end
