class PullerJob < ApplicationJob
  queue_as :default

  def perform(repo)
    user = Repo.find_by(name: repo).user
    user.github.pulls(repo).each do |pull|
      pull_status = user.github.status(repo, pull['head']['ref'])
      @rebase = Rebase.where(github_id: pull['id']).first_or_initialize
      @rebase.update_with_payload(
        payload: { 'repository' => { 'full_name' => repo }, 'pull_request' => pull },
        status: pull_status['statuses'][0]['state']
      )
    end
  end
end
