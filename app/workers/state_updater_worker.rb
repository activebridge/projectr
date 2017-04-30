class StateUpdaterWorker < ApplicationWorker
  def perform(payload)
    Rebase.update_pull_state(payload)
  end
end
