class ApplicationController < ActionController::Base
  before_filter :set_constants

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_constants
    @user = current_user
  end

  def current_ability
    current_user.ability
  end
end
