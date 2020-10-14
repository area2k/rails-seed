# frozen_string_literal: true

# == Schema Information
#
# Table name: devices
#
#  id             :bigint           not null, primary key
#  actor_id       :integer          not null
#  actor_type     :string(32)       not null
#  user_id        :integer          not null
#  uuid           :string(64)       not null
#  refresh_token  :string(32)       not null
#  last_issued    :string(32)       not null
#  last_issued_at :datetime         not null
#  expires_at     :integer          not null
#  user_agent     :string(255)      not null
#  ip             :string(32)       not null
#  client         :string(32)       not null
#  client_version :string(32)       not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_devices_on_refresh_token  (refresh_token) UNIQUE
#  index_devices_on_user_id        (user_id)
#  index_devices_on_uuid           (uuid) UNIQUE
#

class Device < ApplicationRecord
  include Preprocessable

  preprocess uuid: -> { SecureRandom.uuid },
             refresh_token: -> { SecureRandom.hex(16) },
             last_issued: -> { SecureRandom.base36 },
             last_issued_at: -> { Time.now },
             expires_at: -> { Time.now.to_i + Global.auth.device_ttl }

  belongs_to :actor, polymorphic: true
  belongs_to :user

  scope :active, -> { where(table[:expires_at].gt(arel_unix_timestamp)) }

  def active?
    expires_at > Time.now.to_i
  end

  def actor_key
    { id: actor_id, type: actor_type }
  end

  def refresh(jti:, **attrs)
    update!(**attrs, last_issued: jti, last_issued_at: Time.now,
                     expires_at: Time.now.to_i + Global.auth.device_ttl)
  end
end
