class ApiController < ApplicationController
  before_filter :json_authenticate, :except => [:login, :client_version]
  skip_before_filter :verify_authenticity_token

  def json_authenticate
    unless @user = warden.authenticate
      render json: '', :status => :forbidden
    end
  end

  # POST api/auth/login
  # params: username, password
  def login
    username = params[:username]
    resource = User.where(:email => username).first

    if !resource.nil? && resource.valid_password?(params[:password])
      sign_in(resource)
      resource.ensure_authentication_token!
      render json: {
        :auth_token => resource.authentication_token,
        :expiry_ts => (Time.now + Devise.timeout_in).to_i
      }
    else
      render json: '', :status => :forbidden
    end
  end

  # GET api/projects
  # params: username, auth_token
  def projects
    projects = Project.all_manager_of(@user) + Project.all_subscribed_to(@user)
    # Only return relevant attributes
    response = projects.map do |project|
      perm = ProjectPermission.get_user_permission(@user, project).permission
      next {
        :id => project.id,
        :name => project.name,
        :created_ts => project.created_at.to_i,
        :last_commit_hash => ProjectChange.all_project_updates(project, 1).first.commit_hash,
        :can_write => [ProjectPermission::OWNER, ProjectPermission::COAUTHOR].include?(perm)
      }
    end
    render json: response
  end

  # GET api/client_version
  def client_version
    render json: {:version => '1.0.0.0'}
  end
 
  # PUT api/users/public_keys
  # params: username, auth_token, name, public_key
  def public_keys
    if params[:name] && key = UserPublicKey.parse_key(params[:public_key])
      key.user = @user
      key.name = params[:name]
      key.enabled = true
      if key.save
        render json: key
      elsif key.errors[:public_key]
        render json: '', :status => :conflict
      else
        render json: '', :status => :internal_server_error
      end
    else
      render json: '', :status => :bad_request
    end
  end
end
