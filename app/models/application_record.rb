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

  def id_name
    "#{self.class.name}##{id}"
  end

  def saved_attributes(except: %w[updated_at])
    saved_changes.except(*except)
  end

  def to_actor_key
    { id: id, parent_id: respond_to?(:parent_id) ? parent_id : nil, type: base_class_name }
  end
end
