class SessionsController < ApplicationController
  skip_before_action :require_user

  def create
    user = User.where(github_id: github_id).first_or_initialize
    user.update_with_github(
      github_user,
      token
    )
    session[:user_id] = user.id
    redirect_to projects_path
  end

  def destroy
    session.delete :auth_token
    reset_session
    redirect_to root_path
  end

  private

  def token
    @token ||= github.exchange_code_for_token(params[:code])['access_token']
  end

  def github_id
    @github_id ||= github_user.id
  end

  def github_user
    @github_user ||= Octokit::Client.new(access_token: token).user
  end
end
