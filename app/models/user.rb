# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :bigint           not null, primary key
#  uuid                 :string(64)       not null
#  email                :string(128)      not null
#  first_name           :string(64)
#  last_name            :string(64)
#  locale               :string(8)        default("en-US"), not null
#  password_digest      :string(64)
#  password_reset_token :string(32)
#  password_stale       :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#  index_users_on_uuid   (uuid) UNIQUE
#

class User < ApplicationRecord
  include Preprocessable
  include Searchable

  preprocess uuid: -> { SecureRandom.hex }
  searchable on: %i[uuid email first_name last_name]

  has_many :active_devices, -> { active.order(last_issued_at: :desc) }, class_name: 'Device'
  has_many :devices

  def name
    "#{first_name} #{last_name}"
  end

  def password=(value)
    self.password_digest = value ? PasswordService.hash(value) : nil
  end

  def password?
    password_digest.present?
  end

  def valid_password?(value)
    password? && PasswordService.valid?(value, password_digest)
  end
end
