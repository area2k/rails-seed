# frozen_string_literal: true

require 'active_support/concern'

module Preprocessable
  extend ActiveSupport::Concern

  included do
    class_attribute :preprocess_attributes

    before_create :run_preprocess_attributes
  end

  class_methods do
    def preprocess(**attribute_processes)
      attribute_processes.each do |attr, callable|
        validate_attribute!(attr)
        raise "Action for #{attr} not callable" unless callable.respond_to?(:call)
      end

      self.preprocess_attributes = attribute_processes
    end

    private

    def validate_attribute!(attr)
      valid = column_names.map(&:to_sym).include?(attr)
      raise "Invalid attribute: #{attr}" unless valid
    rescue ActiveRecord::ActiveRecordError
      # NOTE: swallow error. this is most likely occurring because the database
      #   has not been created for this environment yet, or a migration is pending
      Rails.logger.error "Unable to check if #{attr} is valid for preprocessing"
    end
  end

  def run_preprocess_attributes
    self.class.preprocess_attributes.each do |attr, callable|
      self[attr] = callable.call
    end
  end
end
