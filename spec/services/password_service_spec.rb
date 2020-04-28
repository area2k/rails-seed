describe PasswordService do
  context 'hash' do
    it 'should create a bcrypt hash' do
      expect(PasswordService.hash('password')).to start_with '$2a$10$'
    end
  end

  context 'valid?' do
    let(:password) { 'super-secure' }
    let(:attempt) { password }

    before do
      @result = PasswordService.valid?(attempt, PasswordService.hash(password))
    end

    context 'when password is not valid' do
      let(:attempt) { 'incorrect-password' }

      it 'should return false' do
        expect(@result).to be false
      end
    end

    it 'should return true' do
      expect(@result).to be true
    end
  end
end
