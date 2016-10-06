class WelcomeController < ApplicationController
  skip_before_action :require_user
  before_action :require_guest, only: :index

  layout 'landing'

  def show
    render params[:page]
  end

  private

  def require_guest
    redirect_to projects_path if current_user
  end
end
