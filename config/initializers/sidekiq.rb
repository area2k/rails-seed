require 'sidekiq'
require 'sidekiq/web'

uri = ENV.fetch(ENV.fetch('REDIS_PROVIDER', 'REDIS_URL'))

Sidekiq.configure_server do |config|
  config.redis = { url: uri }
end

Sidekiq.configure_client do |config|
  config.redis = { url: uri }
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV['SIDEKIQ_WEB_USER'], ENV['SIDEKIQ_WEB_PASS']]
end
