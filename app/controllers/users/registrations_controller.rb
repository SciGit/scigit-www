class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  autocomplete :user, :email, :extra_data => [:fullname], :display_value => :composite_fullname_email

  def show

  end

  def new
    super
  end

  def create
    super
  end

  def update
    super
  end

  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  # The path used after sign up for inactive accounts. You need to overwrite
  # this method in your own RegistrationsController.
  def after_inactive_sign_up_path_for(resource)
    root_path
  end

  # The default url to be used after updating a resource. You need to overwrite
  # this method in your own RegistrationsController.
  def after_update_path_for(resource)
    signed_in_root_path(resource)
  end

  # XXX: Yuck. When Rails 4 is out proper I'm sure people will be screaming
  # about this shit until it gets fixed properly. For now we need to use
  # this crap.

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:fullname, :email, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:fullname, :email, :password, :password_confirmation, :current_password)
    end
  end
end
