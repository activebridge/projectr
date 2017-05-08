class RefresherWorker < ApplicationWorker
  def perform(repo, base = '')
    user = Repo.find_by_name!(repo).user
    pulls =
      if base.present?
        user.github.pulls(repo).select { |a| a['base']['ref'] == base }
      else
        user.github.pulls(repo)
      end
    pulls.each do |pull|
      pr = user.github.pull(repo, pull['number'])
      RebaserWorker.new.perform('repository' => { 'full_name' => repo }, 'pull_request' => pr)
    end
  rescue ActiveRecord::RecordNotFound
    return
  end
end
