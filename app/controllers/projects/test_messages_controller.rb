class Projects::TestMessagesController < ApplicationController
  def create
    SenderJob.new.perform(
      repo: params[:project_id],
      channel_url: params[:channel_url],
      status: 'test'
    )
    head :ok
  end
end
