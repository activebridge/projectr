require 'sidekiq/api'

class DynamicWorker
  def self.call(repo_name, worker, *args)
    Sidekiq::Client.enqueue_to(self.queue_name(repo_name), worker, *args)
  end

  def self.queue_name(name)
    "queue_#{name}".gsub(/[\/]/, '_')
  end
end
