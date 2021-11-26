describe Mutations::DeviceRefreshToken do
  let(:device) { create(:device) }
  let(:refresh_token) { device.refresh_token }

  before do
    query = <<~GRAPHQL
      mutation DeviceRefreshToken($refreshToken: String!) {
        deviceRefreshToken(refreshToken: $refreshToken) {
          accessToken
          problem {
            code
          }
        }
      }
    GRAPHQL

    execute_query(query, refreshToken: refresh_token)
  end

  context 'when device is expired' do
    let(:device) { create(:device, :expired)}

    it 'should return a problem' do
      expect_problem_with 'deviceRefreshToken', 'DEVICE_EXPIRED'
    end
  end

  context 'when refresh token is invalid' do
    let(:device) { nil }
    let(:refresh_token) { SecureRandom.hex }

    it 'should return a problem' do
      expect_problem_with 'deviceRefreshToken', 'INVALID_TOKEN'
    end
  end

  it 'should work' do
    expect(@data['deviceRefreshToken']['accessToken']).to be_a String
    expect(@data['deviceRefreshToken']['problem']).to be_nil
  end
end
