# frozen_string_literal: true

require 'active_support/concern'

module FilterSearchable
  extend ActiveSupport::Concern

  included do
    filter :search do |rel, _op, value|
      rel.search(value)
    end
  end
end
