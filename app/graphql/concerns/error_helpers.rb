# frozen_string_literal: true

module ErrorHelpers
  extend ActiveSupport::Concern

  def error!(**kwargs)
    raise Errors::BaseError.new(**kwargs)
  end
end
