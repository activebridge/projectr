class ProjectsController < ApplicationController
  before_action :check_repo, only: :show

  def index
    @repos = current_user.github.repos.select { |a| a.permissions.admin }
  end

  def update
    if repo.update(repo_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def create
    git_repo = current_user.github.repo(params[:id])
    @repo = current_user.repos.build(name: params[:id], ssh: git_repo['ssh_url'], collaborators: collaborators)
    @repo.save
    current_user.github.create_hook(params[:id], 'web', { url: webhook }, { events: ['push', 'pull_request'] }) unless hook_url
    current_user.github.add_deploy_key(params[:id], 'ProjectR', ssh_key) unless deploy_key
    render :show
  end

  def show
    @pulls = repo.rebases.where(state: 'open').order('created_at')
  end

  private

  def ssh_key
    @ssh_key = `cat ~/.ssh/id_rsa.#{repo.name.parameterize}.pub`.strip
  end

  def collaborators
    @collaborators ||= current_user.github.collaborators(params[:id]).map(&:id)
  end

  def github_hooks
    @github_hooks ||= current_user.github.hooks(params[:id])
  end

  def github_dkeys
    @github_dkeys ||= current_user.github.deploy_keys(params[:id])
  end

  def hook_url
    github_hooks.any? { |h| h['config']['url'] == webhook }
  end

  def deploy_key
    github_dkeys.any? { |d| d['key'] == ssh_key.split[0..1].join(' ') }
  end

  def webhook
    @webhook ||= webhook_url(host: ENV['host'], port: nil)
  end

  def repo
    @repo ||= current_user.repos.find_by(name: params[:id])
  end
  helper_method :repo

  def check_repo
    send :create unless repo
  end

  def repo_params
    params.require(:repo).permit(:auto_rebase)
  end
end
