module Support
  module Requests
    def app
      described_class
    end

    def expect_status(status, code: nil)
      expect(last_response.status).to eql status
      expect(json[:code]).to eql code if code
    end

    def json
      JSON.parse(last_response.body).deep_symbolize_keys
    end

    def redirect_location
      last_response.headers['Location']
    end
  end
end
