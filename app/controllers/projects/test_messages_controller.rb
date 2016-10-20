class Projects::TestMessagesController < ApplicationController
  def create
    SenderJob.new.perform(repo: repo, status: 'test')
    head :ok
  end

  private

  def repo
    @repo ||= Repo.find_by(name: params[:project_id])
  end
end
