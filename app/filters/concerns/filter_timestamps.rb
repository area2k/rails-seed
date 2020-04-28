# frozen_string_literal: true

require 'active_support/concern'

module FilterTimestamps
  extend ActiveSupport::Concern

  included do
    filter :created_at
    filter :updated_at
  end
end
