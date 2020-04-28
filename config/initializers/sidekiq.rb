require 'sidekiq'
require 'sidekiq/web'

uri = ENV['REDISTOGO_URL'] || 'redis://localhost:6379/4'

Sidekiq.configure_server do |config|
  config.redis = { url: uri }
end

Sidekiq.configure_client do |config|
  config.redis = { url: uri }
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [ENV['SIDEKIQ_WEB_USER'], ENV['SIDEKIQ_WEB_PASS']]
end
