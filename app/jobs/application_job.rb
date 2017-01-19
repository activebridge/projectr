class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  APPLICATION_TITLE = 'ProjectR'.freeze

  private

  def set_status(status, options = {})
    @rebase.user.github.create_status(@rebase.repo, @rebase.sha, status, options.merge(context: APPLICATION_TITLE))
  end

  def status
    status = @rebase.user.github.status(@rebase.repo, @rebase.head).to_h
    rebase_status = status[:statuses]&.find{|status| status[:context] == APPLICATION_TITLE }&.dig(:state)
    rebase_status ? rebase_status : 'undefined'
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
