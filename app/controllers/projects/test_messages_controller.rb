class Projects::TestMessagesController < ApplicationController
  def create
    DynamicWorker.call(
      params[:project_id],
      SenderWorker,
      repo: params[:project_id],
      channel_url: params[:channel_url],
      status: 'test'
    )
    head :ok
  end
end
