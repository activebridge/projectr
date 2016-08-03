class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :require_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def github
    @github ||= Octokit::Client.new(client_id: ENV['github_token'], client_secret: ENV['github_secret'])
  end

  def require_user
    head 404 unless current_user
  end
end
