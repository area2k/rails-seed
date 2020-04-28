# frozen_string_literal: true

module Finders
  extend ActiveSupport::Concern

  def find!(model, **query)
    model.find_by!(**query)
  rescue ActiveRecord::RecordNotFound
    raise Errors::ModelNotFoundError.new(model: model, query: query)
  end

  def find(model, **query)
    find!(model, **query)
  rescue Errors::ModelNotFoundError
    nil
  end
end
