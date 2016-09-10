class WelcomeController < ApplicationController
  skip_before_action :require_user
  layout 'landing'
end
