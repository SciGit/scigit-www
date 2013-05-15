class MainController < ApplicationController
  def index
    if user_signed_in?
      @coauthor_updates = ProjectChange.all
      @subscription_updates = ProjectChange.all
      render 'main/home' # home.html.erb
    else
      render
    end
  end
end
