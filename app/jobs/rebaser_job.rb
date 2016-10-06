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
      set_status('pending', description: "branch has 'work in progress' label.")
    elsif github.rebase == 'conflict'
      set_status('error', description: 'branch has conflicts that must be resolved')
    elsif github.rebase == 'fail'
      set_status('failure', description: 'branch is out of date. Click Details to rebase', target_url: edit_rebase_url(rebase, host: ENV['host']))
      PusherJob.new.perform(rebase) if repo.auto_rebase
    else
      set_status('success', description: 'Your branch is up to date')
    end
  end

  def work_in_progress(title)
    title.scan(/\B#\w+/).any? { |l| l.casecmp('#wip') == 0 }
  end
end
