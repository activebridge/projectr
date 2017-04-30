require 'sidekiq'
require 'sidekiq/fetch'

class DynamicFetch < Sidekiq::BasicFetch
  def queues_cmd
    queues = Sidekiq.redis { |conn| conn.smembers('queues') }
    queues.map! { |q| "queue:#{q}" }

    if queues.empty?
      return super
    else
      @queues = queues
    end

    @unique_queues = @queues.uniq
    super
  end
end
