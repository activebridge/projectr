Rollbar.configure do |config|
  config.access_token = ENV['rollbar_token']

  config.enabled = Rails.env.production?

  config.environment = ENV['ROLLBAR_ENV'] || Rails.env
end
