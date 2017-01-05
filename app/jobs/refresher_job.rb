class RefresherJob < ApplicationJob
  queue_as :default

  def perform(repo, base = '')
    user = Repo.find_by(name: repo).user
    pulls = base.present? ? user.github.pulls(repo).select { |a| a['base']['ref'] == base } : user.github.pulls(repo)
    pulls.each do |pull|
      pr = user.github.pull(repo, pull['number'])
      RebaserJob.perform_now('repository' => { 'full_name' => repo }, 'pull_request' => pr)
    end
  end
end
