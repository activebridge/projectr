require 'sidekiq/testing'
RSpec.configure do |config|
  Sidekiq::Testing.fake!
  Sidekiq::Testing.inline!
  config.before do
    Sidekiq::Worker.clear_all
  end
end
