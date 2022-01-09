FactoryBot.define do
  factory :device do
    user_id { 1 }
    user_agent { 'FactoryBot/RSpec' }
    ip { '0.0.0.0' }
    client { 'RSpec' }
    client_version { 'v0' }

    trait :expired do
      expires_at { 0 }
    end

    trait :with_user do
      user { create(:user) }
    end
  end
end
