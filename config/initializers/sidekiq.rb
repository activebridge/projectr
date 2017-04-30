require 'sidekiq/web'
require './lib/dynamic_fetch'

redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379'

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  config.options[:fetch] = DynamicFetch
end

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == ['admin', 'activebridge']
end
