class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  private

  def set_status(status, options = {})
    @rebase.user.github.create_status(@rebase.repo, @rebase.sha, status, options.merge(context: 'ProjectR'))
  end

  def status
    begin
      status = @rebase.user.github.status(@rebase.repo, @rebase.head)
      status['statuses'][0]['state']
    rescue Octokit::NotFound
      repo = Repo.find_by(name: @rebase.repo)
      SenderJob.new.perform(repo: repo, rebase: @rebase, status: 'branch_not_found') if repo.channel_url
    end
  end

  def state
    pull = @rebase.user.github.pull(@rebase.repo, @rebase.number)
    pull['state']
  end

  def cleaner_config(path, name)
    config = File.read(path)
    key = config.match(/\n.*#{name.parameterize}.*\n.*\n.*\n.*\n/).to_s
    config.gsub!(key, '')
    File.open(path, 'w') { |file| file.puts config }
  end

  def github
    Github.new(@rebase)
  end
end
