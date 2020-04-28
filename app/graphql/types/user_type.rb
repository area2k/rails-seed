# frozen_string_literal: true

module Types
  class UserType < BaseObject
    include Timestamps
    include UUID

    description 'User'

    field :email, Scalars::Email, null: false
    field :first_name, String, null: true
    field :last_name, String, null: true
    field :locale, Enums::LocaleEnum, null: false
    field :password_stale, Boolean, null: true

    field :devices, [DeviceType], null: false, preload: true, method: :active_devices
  end
end
