class RebasesController < ApplicationController
  EVENTS = %w[push pull_request].freeze
  ACTIONS = %w[opened reopened synchronize edited].freeze

  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :require_user, only: :create

  before_action :check_for_access, only: :update

  def create
    send(event) if EVENTS.include?(event)
    head 200
  end

  def update
    PusherWorker.new.perform(params[:id])
    respond_to do |format|
      format.html { redirect_to project_path(rebase.repo) }
      format.js
    end
  end

  private

  def event
    @event ||= request.env['HTTP_X_GITHUB_EVENT']
  end

  def push
    `rm -rf #{repo_name}` unless payload['deleted']
    DynamicWorker.call(repo_name, RefresherWorker, repo_name, base)
  end

  def pull_request
    if ACTIONS.include?(payload['action'])
      DynamicWorker.call(repo_name, RebaserWorker, payload)
    else
      DynamicWorker.call(repo_name, StateUpdaterWorker, payload)
    end
  end

  def repo_name
    @repo_name ||= payload['repository']['full_name']
  end

  def base
    @base ||= payload['ref'].split('/').last
  end

  def rebase
    @rebase ||= Rebase.find(params[:id])
  end

  def check_for_access
    head :unprocessable_entity unless access
  end

  def access
    repo = Repo.find_by(name: rebase.repo)
    repo.collaborators.include?(current_user.github_id)
  end

  def payload
    JSON.parse(params[:payload])
  end
end
