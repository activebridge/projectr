class ApplicationWorker
  include Rails.application.routes.url_helpers
  include Sidekiq::Worker

  APPLICATION_TITLE = 'ProjectR'.freeze

  private

  def set_status(status, options = {})
    return unless repo
    @rebase.user.github.create_status(
      @rebase.repo, @rebase.sha, status,
      options.merge(context: APPLICATION_TITLE)
    )
  end

  def status
    return unless repo
    status = @rebase.user.github.status(@rebase.repo, @rebase.head)
    status[:statuses] ? status[:statuses][0][:state] : 'undefined'
  rescue Octokit::NotFound
    'undefined'
  end

  def state
    return unless repo
    pull = @rebase.user.github.pull(@rebase.repo, @rebase.number)
    pull['state']
  end

  def repo
    @repo = @rebase.repository
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
