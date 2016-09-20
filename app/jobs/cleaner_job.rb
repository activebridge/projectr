class CleanerJob < ApplicationJob
  queue_as :default

  def perform(name, user)
    key = `cat ~/.ssh/id_rsa.#{name.parameterize}.pub`.strip
    url = "#{ENV['host']}/webhook"
    @hook = user.github.hooks(name).find { |h| h['config']['url'] == url }
    @deploy_key = user.github.deploy_keys(name).find { |a| a['key'] == key.split[0..1].join(' ') }
    user.github.remove_deploy_key(name, @deploy_key.id) if @deploy_key
    user.github.remove_hook(name, @hook.id) if @hook
    `rm ~/.ssh/id_rsa.#{name.parameterize}`
    `rm ~/.ssh/id_rsa.#{name.parameterize}.pub`
    cleaner_config(File.expand_path('~/.ssh/config'), name)
  end
end
