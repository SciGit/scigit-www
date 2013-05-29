class MainController < ApplicationController
  def index
    if user_signed_in?
      @coauthor_updates = ProjectChange.get_coauthor_updates(current_user, 20)
      @subscription_updates = ProjectChange.get_subscription_updates(current_user, 20)
      render 'main/home' # home.html.erb
    else
      render
    end
  end
end
