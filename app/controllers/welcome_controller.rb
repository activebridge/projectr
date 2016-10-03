class WelcomeController < ApplicationController
  skip_before_action :require_user
  layout 'landing'
  def show
    render params[:page]
  end
end
