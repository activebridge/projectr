class RebaserJob < ApplicationJob
  queue_as :default

  def perform(payload)
    pull_request_id = payload['pull_request']['id']
    @rebase = Rebase.where(github_id: pull_request_id).first_or_initialize
    @rebase.update_from_payload(payload)
    @repo = Repo.find_by(name: @rebase.repo)
    set_status('pending', description: 'Running...')
    if github.rebase == 'conflict'
      set_status('error', description: 'branch has conflicts that must be resolved')
    elsif github.rebase == 'fail'
      set_status('failure', description: 'branch is out of date. Click Details to rebase', target_url: edit_rebase_url(@rebase, host: ENV['host']))
      PusherJob.new.perform(@rebase) if @repo.auto_rebase
    else
      set_status('success', description: 'Your branch is up to date')
    end
    @rebase.update_attributes(status: status, state: state)
  end
end
