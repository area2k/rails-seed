# frozen_string_literal: true

require 'active_support/concern'

module Discardable
  extend ActiveSupport::Concern

  included do
    scope :discarded, -> { where.not(discarded_at: nil) }
    scope :kept, -> { where(discarded_at: nil) }
  end

  def discard
    update!(discarded_at: Time.now.utc)
  end

  def discardable?
    true
  end

  def discarded?
    discarded_at?
  end

  def kept?
    !discarded?
  end
end
