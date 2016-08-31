class RebasesController < ApplicationController
  EVENTS = %w(push pull_request).freeze
  ACTIONS = %w(opened reopened synchronize).freeze

  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :require_user, only: :create

  before_action :check_for_access, only: :update

  def create
    send(event) if EVENTS.include?(event)
    head 200
  end

  def update
    PusherJob.new.perform(rebase)
    head 200
  end

  private

  def event
    @event ||= request.env['HTTP_X_GITHUB_EVENT']
  end

  def push
    return unless process?
    RefresherJob.new.perform(payload['repository']['full_name'])
  end

  def pull_request
    RebaserJob.new.perform(payload) if ACTIONS.include?(payload['action'])
  end

  def process?
    payload['ref'].eql?('refs/heads/master')
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
