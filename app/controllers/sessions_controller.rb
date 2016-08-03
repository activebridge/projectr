class SessionsController < ApplicationController
  skip_before_action :require_user

  def create
    token = github.exchange_code_for_token(params[:code])['access_token']
    user = User.where(token: token).first_or_initialize
    user.update_with_github(Octokit::Client.new(access_token: token).user)
    session[:user_id] = user.id
    redirect_to new_project_path
  end
end
