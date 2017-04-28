class ProjectsController < ApplicationController
  before_action :check_repo, only: :show

  def index
    @repos = current_user.github.repos.select { |a| a.permissions.admin }
  end

  def update
    repo.update(repo_params)
  end

  def create
    @repo = current_user.repos.build(name: params[:id])
    if @repo.valid? && @repo.save
      RefresherJob.new.perform(@repo.name)
      render :show
    else
      @errors = @repo.errors
    end
  end

  def destroy
    repo.destroy
    redirect_to projects_path
  end

  private

  def repo
    @repo ||= current_user.repos.find_by!(name: params[:id])
  end
  helper_method :repo

  def pulls
    @pulls ||= repo.rebases.where(state: 'open').order('created_at')
  end
  helper_method :pulls

  def check_repo
    send :create unless current_user.repos.any? { |r| r.name == params[:id] }
  end

  def repo_params
    params.require(:repo).permit(:auto_rebase, :channel_url)
  end
end
