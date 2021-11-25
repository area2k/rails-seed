# frozen_string_literal: true

module Types
  class DeviceType < BaseObject
    description 'Device'

    implements Interfaces::Node
    implements Interfaces::HasTimestamps

    field :last_issued, String, null: false
    field :last_issued_at, GraphQL::Types::ISO8601DateTime, null: false
    field :expires_at, Scalars::NonNegativeInt, null: false
    field :user_agent, String, null: false
    field :ip, String, null: true
    field :client, String, null: false
    field :client_version, String, null: false

    field :user, UserType, null: false, method: :user_id do
      extension Extensions::Dataloadable, association: :user
    end
  end
end
