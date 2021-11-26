describe Mutations::UserForgotPassword do
  let(:user) { create(:user) }
  let(:email) { user.email }

  before do
    query = <<~GRAPHQL
      mutation UserForgotPassword($email: Email!) {
        userForgotPassword(email: $email)
      }
    GRAPHQL

    execute_query(query, email: email)
  end

  context 'when email is not valid' do
    let(:email) { "#{SecureRandom.hex}@example.com" }

    it 'should fail silently' do
      expect(@data['userForgotPassword']).to be_nil
      expect(user.reload.password_reset_token).to be_nil
    end
  end

  it 'should work' do
    expect(@data['userForgotPassword']).to be_nil
    expect(user.reload.password_reset_token).to_not be_nil

    # TODO: check if email is enqueued
  end
end
