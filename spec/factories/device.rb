FactoryBot.define do
  factory :device do
    actor_id { 1 }
    actor_type { 'User' }
    user_agent { 'FactoryBot/RSpec' }
    ip { '0.0.0.0' }
    client { 'RSpec' }
    client_version { 'v0' }

    trait :expired do
      expires_at { 0 }
    end
  end
end
