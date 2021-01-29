require 'sidekiq'
require 'sidekiq/web'

REDIS_URI = ENV.fetch(ENV.fetch('REDIS_PROVIDER', 'REDIS_URL'))

SIDEKIQ_CREDS = Rails.application.credentials.sidekiq!
SIDEKIQ_USERNAME = SIDEKIQ_CREDS.fetch(:username)
SIDEKIQ_PASSWORD = SIDEKIQ_CREDS.fetch(:password)

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_URI }
end

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URI }
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [SIDEKIQ_USERNAME, SIDEKIQ_PASSWORD]
end
