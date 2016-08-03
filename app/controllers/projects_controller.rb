class ProjectsController < ApplicationController
  def new
    @repos = current_user.github.repos
  end

  def update
    repo = current_user.github.repo(params[:id])
    @repo = current_user.repos.build(name: params[:id], ssh: repo['ssh_url'])
    render :show
    return unless @repo.save
    current_user.github.create_hook(params[:id], 'web', { url: webhook_url(host: ENV['host'], port: nil) }, { events: ['push', 'pull_request'] })
  end

  private

  def repo
    @repo ||= current_user.repos.find(params[:id])
  end
  helper_method :repo
end
