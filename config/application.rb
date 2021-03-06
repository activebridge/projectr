require_relative 'boot'

require 'rails/all'
require './lib/dynamic_worker'
require './lib/github'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Projectr
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq
  end
end

Rails.application.secrets.each { |key, value| ENV[key.to_s] ||= value }
I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]
