class UsersController < ApplicationController
  before_filter :authenticate_user!
  autocomplete :user, :email, :extra_data => [:email, :fullname], :display_value => :composite_fullname_email

  def show
  end

  def settings
    @user = current_user
    @public_keys = UserPublicKey.where(:user => @user)
  end

  def update_settings
    if !params[:delete_public_key].nil?
      redirect_to users_settings_url + '#ssh'
    elsif params[:submit] == 'Save Profile'
    end
  end
end
