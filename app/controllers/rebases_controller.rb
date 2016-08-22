class RebasesController < ApplicationController
  EVENTS = %w(push pull_request).freeze

  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :require_user, only: :create

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
    RebaserJob.new.perform(payload) if payload['action'].include?('opened' || 'synchronize')
  end

  def process?
    payload['ref'].eql?('refs/heads/master')
  end

  def rebase
    @rebase ||= current_user.rebases.find(params[:id])
  end

  def payload
    JSON.parse(params[:payload])
  end
end
