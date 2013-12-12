class ProjectPermissionsController < ApplicationController
  before_action :set_project_permission, only: [:show, :edit, :update, :destroy]
  before_action :load_project

  # GET /project_permissions
  # GET /project_permissions.json
  def index
    @project_permissions = ProjectPermission.all
  end

  # GET /project_permissions/1
  # GET /project_permissions/1.json
  def show
  end

  # GET /project_permissions/new
  def new
    @project_permission = ProjectPermission.new
    @project_permission.build_user
    @project_permission.build_project
    render :layout => false
  end

  # GET /project_permissions/1/edit
  def edit
  end

  # POST /project_permissions
  # POST /project_permissions.json
  def create
    email = project_permission_params[:user_attributes][:email]
    user = User.find_by(:email => email)
    project = Project.find(params[:project_id])
    if user
      @project_permission = ProjectPermission.new(:user => user, :project => project,
                                                  :permission => project_permission_params[:permission])
    else
    end

    respond_to do |format|
      if @project_permission.save
        format.html { redirect_to @project_permission, notice: 'Project permission was successfully created.' }
        format.json { render json: {
          :redirect => project_path(project.id),
          :notice => "#{user.fullname} has been added to #{project.name}.",
        } }
      else
        format.html { render action: 'new' }
        format.json { render json: @project_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /project_permissions/1
  # PATCH/PUT /project_permissions/1.json
  def update
    respond_to do |format|
      if @project_permission.update(project_permission_params)
        format.html { redirect_to @project_permission, notice: 'Project permission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /project_permissions/1
  # DELETE /project_permissions/1.json
  def destroy
    project = @project_permission.project
    user = @project_permission.user
    @project_permission.destroy
    redirect_to project, notice: "#{user.fullname} has been removed from #{project.name}."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project_permission
      @project_permission = ProjectPermission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_permission_params
      params.require(:project_permission).permit(:permission, user_attributes: [:composite_fullname_email, :email], project_attributes: [:id])
    end

    def load_project
      @project = Project.find(params[:project_id])
    end
end
