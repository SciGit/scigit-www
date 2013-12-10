class UsersController < ApplicationController
  before_filter :authenticate_user!
  autocomplete :user, :email, :extra_data => [:email, :fullname], :display_value => :composite_fullname_email

  def show
  end

  def settings
    @user = current_user
    @public_keys = UserPublicKey.where(:user => @user, :enabled => true)
  end

  def update_settings
    @user = current_user
    if @user.update_attributes(params.require(:user).permit(:disable_email))
      render json: {:notice => 'Settings saved.'}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end
  
  def update_profile
    @user = current_user
    if @user.update_attributes(params.require(:user).permit(:email, :fullname, :organization, :location, :about))
      render json: {:notice => 'Profile saved.'}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def change_password
    @user = current_user
    if !params[:user] || params[:user][:password].empty?
      render status: :unprocessable_entity, json: {:password => 'must be provided'}
    elsif @user.update_with_password(params.require(:user).permit(:current_password, :password, :password_confirmation))
      sign_in @user, :bypass => true # don't sign out
      render json: {:notice => 'Password successfully changed.'}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def add_public_key
    pkey = UserPublicKey.parse_key(params[:public_key])
    if pkey.nil?
      return render json: {:public_key => 'invalid or corrupt. Please ensure you entered it correctly.'}, status: :unprocessable_entity
    elsif old_key = UserPublicKey.where(:user => current_user, :public_key => pkey.public_key, :enabled => 0).first
      old_key.update_attributes(:enabled => 1)
    else
      pkey.user = current_user
      pkey.name = params[:name]
      pkey.enabled = true
      if !pkey.save
        return render json: pkey.errors, status: :unprocessable_entity
      end
    end

    flash[:pkey_notice] = 'Key successfully added.'
    render json: {:notice => 'Key successfully added.', :url => users_settings_path + '#ssh'}
  end

  def delete_public_key
    id = params[:delete_public_key]
    key = UserPublicKey.where(:id => id).first
    if key && key.user == @user
      key.update_attributes(:enabled => 0)
      flash[:pkey_notice] = 'Key successfully deleted.'
    end
    redirect_to users_settings_path + '#ssh'
  end
end
