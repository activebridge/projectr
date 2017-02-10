class RebasesController < ApplicationController
  EVENTS = %w(push pull_request).freeze
  ACTIONS = %w(opened reopened synchronize edited).freeze

  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :require_user, only: :create

  before_action :check_for_access, only: :update

  def create
    send(event) if EVENTS.include?(event)
    head 200
  end

  def update
    PusherJob.new.perform(rebase)
    respond_to do |format|
      format.html { head 200 }
      format.js
    end
  end

  private

  def event
    @event ||= request.env['HTTP_X_GITHUB_EVENT']
  end

  def push
    `rm -rf #{repo_name}` unless payload['deleted']
    RefresherJob.new.perform(repo_name, base)
  end

  def pull_request
    RebaserJob.new.perform(payload) if ACTIONS.include?(payload['action'])
    @rebase = Rebase.find_by(github_id: payload['pull_request']['id'])
    @rebase.update_attributes(state: payload['pull_request']['state'])
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
