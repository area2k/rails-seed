# frozen_string_literal: true

module Types
  class UserType < BaseObject
    description 'User'

    implements Interfaces::Node
    implements Interfaces::HasTimestamps

    field :email, Scalars::Email, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :locale, Enums::LocaleEnum, null: false
    field :password_stale, Boolean, null: true

    field :devices, [DeviceType], null: false, method: :id do
      extension Extensions::Dataloadable, association: :active_devices
    end
  end
end
