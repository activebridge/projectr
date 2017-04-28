class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  APPLICATION_TITLE = 'ProjectR'.freeze

  private

  def set_status(status, options = {})
    @rebase.user.github.create_status(
      @rebase.repo, @rebase.sha,
      status, options.merge(context: APPLICATION_TITLE)
    )
  end

  def status
    status = @rebase.user.github.status(@rebase.repo, @rebase.head)
    status[:statuses][0][:state]
  rescue Octokit::NotFound
    'undefined'
  end

  def state
    pull = @rebase.user.github.pull(@rebase.repo, @rebase.number)
    pull['state']
  end

  def cleaner_config(path, name)
    config = File.read(path)
    key = SSH::SSH_CONFIG % { name: name.parameterize }
    config.gsub!(key, '')
    File.open(path, 'w') { |file| file.puts config }
  end

  def github
    Github.new(@rebase)
  end
end
