describe Mutations::DeviceGrantToken do
  let(:device) { create(:device, :with_user) }
  let(:refresh_token) { device.refresh_token }
  let(:actor) { { id: device.user.uuid, kind: 'USER' } }

  before do
    query = <<~GRAPHQL
      mutation DeviceGrantToken($deviceToken: String!, $actor: ActorInput!) {
        deviceGrantToken(deviceToken: $deviceToken, actor: $actor) {
          accessToken
          problem {
            code
          }
        }
      }
    GRAPHQL

    execute_query(query, deviceToken: refresh_token, actor: actor)

    expect_no_errors
  end

  context 'when device is expired' do
    let(:device) { create(:device, :expired, :with_user)}

    it 'should return a problem' do
      expect_problem_with 'deviceGrantToken', 'DEVICE_EXPIRED'
    end
  end

  context 'when refresh token is invalid' do
    let(:refresh_token) { SecureRandom.hex }

    it 'should return a problem' do
      expect_problem_with 'deviceGrantToken', 'INVALID_TOKEN'
    end
  end

  context 'when actor is not found' do
    let(:actor) { { id: 'invalid', kind: 'USER' } }

    it 'should return a problem' do
      expect_problem_with 'deviceGrantToken', 'INVALID_ACTOR'
    end
  end

  context 'when actor is not allowed to be accessed' do
    let(:actor) { { id: create(:user).uuid, kind: 'USER' } }

    it 'should return a problem' do
      expect_problem_with 'deviceGrantToken', 'INVALID_ACTOR'
    end
  end

  it 'should return an access token' do
    expect_no_problem_with 'deviceGrantToken'

    access_token = @data['deviceGrantToken']['accessToken']
    expect(access_token).to be_a String

    auth_context = AuthenticationService.validate(access_token)
    expect(auth_context).to be_a AuthenticationService::AuthContext

    expect(auth_context.device_id).to eq device.id
    expect(auth_context.actor_id).to eq device.user_id
    expect(auth_context.actor_kind).to eq User
  end
end
