class ApplicationJob < ActiveJob::Base
  include Rails.application.routes.url_helpers

  private

  def set_status(status, options = {})
    @rebase.user.github.create_status(@rebase.repo, @rebase.sha, status, options.merge(context: 'ProjectR'))
  end

  def github
    Github.new(@rebase)
  end
end
