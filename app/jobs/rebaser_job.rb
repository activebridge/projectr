class RebaserJob < ApplicationJob
  queue_as :default

  def perform(payload)
    @rebase = Rebase.from_payload(payload)
    set_status('pending', description: 'Running...')
    if github.rebase == 'conflict'
      set_status('error', description: 'branch has conflicts that must be resolved')
    elsif github.rebase == 'fail'
      set_status('failure', description: 'branch is out of date. Click Details to rebase', target_url: edit_rebase_url(@rebase, host: ENV['host']))
    else
      set_status('success', description: 'Your branch is up to date')
    end
  end
end
