class HomeController < ApplicationController
  def index
    if user_signed_in?
      render 'home/home' # home.html.erb
    else
      render
    end
  end
end
