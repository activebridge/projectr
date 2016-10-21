require_relative 'boot'

require 'rails/all'
require './lib/github'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Projectr
  class Application < Rails::Application
  end
end

Rails.application.secrets.each { |key, value| ENV[key.to_s] ||= value }
I18n.load_path += Dir[Rails.root.join('lib', 'locale', '*.{rb,yml}')]
