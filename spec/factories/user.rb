FactoryBot.define do
  factory :user do
    first_name { 'Test' }
    sequence(:last_name) { |n| "User #{n}" }
    email { "#{first_name.downcase}.#{last_name.downcase.tr(' ', '_')}@example.com" }

    trait :with_password do
      password { 'Password1' }
    end

    trait :with_reset_token do
      password_reset_token { SecureRandom.hex }
    end
  end
end
