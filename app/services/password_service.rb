# frozen_string_literal: true

module PasswordService
  module_function

  def hash(password)
    BCrypt::Password.create(password)
  end

  def valid?(password, hashed_password)
    BCrypt::Password.new(hashed_password) == password
  end
end
