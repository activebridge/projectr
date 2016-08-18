class RefresherJob < ApplicationJob
  queue_as :default

  def perform(repo)
    user = Repo.find_by(name: repo).user
    user.github.pulls(repo).each do |pull|
      pr = user.github.pull(repo, pull['number'])
      RebaserJob.new.perform('repository' => { 'full_name' => repo }, 'pull_request' => pr)
    end
  end
end
