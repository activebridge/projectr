# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'
SimpleCov.start(:rails)

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'support/factory_girl'
require 'capybara/poltergeist'
require 'rspec/retry'
ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

DEFAULT_PORT = 9887
Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.asset_host = 'http://localhost:3000'
Capybara.server_port = DEFAULT_PORT
Capybara.app_host = "http://lvh.me:#{Capybara.server_port}"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, window_size: [1200, 700], js_errors: false)
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.start
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
