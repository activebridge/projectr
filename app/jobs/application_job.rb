class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  private

  def set_status(status, options = {})
    @rebase.user.github.create_status(@rebase.repo, @rebase.sha, status, options.merge(context: 'ProjectR'))
  end

  def status
    status = @rebase.user.github.status(@rebase.repo, @rebase.head)
    status['statuses'][0]['state']
  end

  def state
    pull = @rebase.user.github.pull(@rebase.repo, @rebase.number)
    pull['state']
  end

  def cleaner_config(path, name)
    config = File.read(path)
    keys = config.split(" \n").each { |a| a << " \n" }
    keys.each do |k|
      config.gsub!(k, '') if k.include?("Host #{name.parameterize} ")
    end
    File.open(path, 'w') { |file| file.puts config }
  end

  def github
    Github.new(@rebase)
  end
end
