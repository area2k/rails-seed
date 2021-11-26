describe Mutations::UserResetPassword do
  let(:user) { create(:user, :with_reset_token) }
  let(:token) { user.password_reset_token }
  let(:new_password) { 'new-password' }

  before do
    query = <<~GRAPHQL
      mutation UserResetPassword($token: String!, $password: String!) {
        userResetPassword(token: $token, password: $password) {
          problem {
            code
          }
        }
      }
    GRAPHQL

    @result = execute_query(query, token: token, password: new_password)
  end

  context 'when token is invalid' do
    let(:token) { SecureRandom.hex }

    it 'should return a problem' do
      expect_problem_with 'userResetPassword', 'INVALID_TOKEN'
      expect(user.reload).to_not be_password
    end
  end

  it 'should work' do
    expect_no_problem_with 'userResetPassword'
    expect(user.reload).to be_valid_password(new_password)
  end
end
