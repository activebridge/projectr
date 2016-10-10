class RebaserJob < ApplicationJob
  queue_as :default

  def perform(payload)
    pull_request_id = payload['pull_request']['id']
    @rebase = Rebase.where(github_id: pull_request_id).first_or_initialize
    @rebase.update_with_payload(payload: payload)
    @repo = Repo.find_by(name: @rebase.repo)
    set_status('pending', description: 'Running...')
    rebase_pr(@rebase, @repo)
    @rebase.update_attributes(status: status, state: state)
  end

  private

  def rebase_pr(rebase, repo)
    if work_in_progress(rebase.title)
      set_status('pending', description: I18n.t('status.work_in_progress'))
    elsif github.rebase == 'conflict'
      set_status('error', description: I18n.t('status.conflict'))
      SenderJob.new.perform(rebase, 'error')
    elsif github.rebase == 'fail'
      set_status('failure', description: I18n.t('status.fail'), target_url: edit_rebase_url(rebase, host: ENV['host']))
      PusherJob.new.perform(rebase) if repo.auto_rebase
    else
      set_status('success', description: I18n.t('status.success'))
      SenderJob.new.perform(rebase, 'success')
    end
  end

  def work_in_progress(title)
    title.scan(/\B#\w+/).any? { |l| l.casecmp('#wip') == 0 }
  end
end
