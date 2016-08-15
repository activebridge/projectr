class ProjectsController < ApplicationController
  before_action :repos, only: :new

  def update
    repo = current_user.github.repo(params[:id])
    @repo = current_user.repos.build(name: params[:id], ssh: repo['ssh_url'])
    render :show
    return unless @repo.save
    current_user.github.create_hook(params[:id], 'web', { url: webhook_url(host: ENV['host'], port: nil) }, { events: ['push', 'pull_request'] })
    current_user.github.add_deploy_key(params[:id], 'ProjectR', ssh_key)
  end

  private

  def ssh_key
    @ssh_key = `cat ~/.ssh/id_rsa.#{repo.name.parameterize}.pub`.strip
  end

  def repo
    @repo ||= current_user.repos.find(params[:id])
  end
  helper_method :repo

  def repos
    @repos = current_user.github.repos.select { |a| a.permissions.admin }
  end
end
