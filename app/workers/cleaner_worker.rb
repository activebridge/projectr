class CleanerWorker < ApplicationWorker
  def perform(name, projectr_user)
    user = User.find(projectr_user)
    remove_repo_queue(name)
    key = `cat #{ENV['key_path']}/id_rsa.#{name.parameterize}.pub`.strip
    url = "#{ENV['host']}/webhook"
    @hook = user.github.hooks(name).find { |h| h['config']['url'] == url }
    @deploy_key = user.github.deploy_keys(name).find { |a| a['key'] == key.split[0..1].join(' ') }
    user.github.remove_deploy_key(name, @deploy_key.id) if @deploy_key
    user.github.remove_hook(name, @hook.id) if @hook
    `rm #{ENV['key_path']}/id_rsa.#{name.parameterize}`
    `rm #{ENV['key_path']}/id_rsa.#{name.parameterize}.pub`
    `rm -rf #{name}`
    cleaner_config(File.expand_path("#{ENV['key_path']}/config"), name)
  end

  private

  def remove_repo_queue(name)
    repo_name = DynamicWorker.queue_name(name)
    Sidekiq.redis do |r|
      r.srem "queues", repo_name
      r.del "queue:#{repo_name}"
    end
  end
end
