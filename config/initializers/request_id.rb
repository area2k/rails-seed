# frozen_string_literal: true

module ActionDispatch
  class RequestId
    private

    def internal_request_id
      RequestStore[:request_id] ||= SecureRandom.base58
    end
  end
end
