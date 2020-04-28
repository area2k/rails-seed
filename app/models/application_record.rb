# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def arel_timestamp
      @arel_timestamp ||=
        Arel::Nodes::NamedFunction.new('CURRENT_TIMESTAMP', []).freeze
    end

    def arel_unix_timestamp
      @arel_unix_timestamp ||=
        Arel::Nodes::NamedFunction.new('UNIX_TIMESTAMP', []).freeze
    end

    def base_class_name
      base_class.name
    end

    def table
      arel_table
    end
  end

  def base_class_name
    self.class.base_class.name
  end

  def saved_attributes(except: %w[updated_at])
    saved_changes.except(*except)
  end
end
