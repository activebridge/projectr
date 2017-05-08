class PusherWorker < ApplicationWorker
  def perform(id)
    @rebase = Rebase.find(id)
    return unless @rebase && @rebase.repository
    set_status('pending', description: 'Rebase in progress')
    if (sha = github.push)
      @rebase.update_attributes(sha: sha.strip, pushed: true)
      set_status('success', description: 'Your branch is up to date')
    else
      set_status('failure', description: 'branch is out of date. Click Details to rebase', target_url: edit_rebase_url(@rebase, host: ENV['host']))
    end
    @rebase.update_attributes(status: status)
    p sha
  end
end
