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
    render :layout => false
  end

  # GET /project_permissions/1/edit
  def edit
  end

  # POST /project_permissions
  # POST /project_permissions.json
  def create
    @project_permission = ProjectPermission.new(project_permission_params)

    respond_to do |format|
      if @project_permission.save
        format.html { redirect_to @project_permission, notice: 'Project permission was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project_permission }
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
    @project_permission.destroy
    respond_to do |format|
      format.html { redirect_to project_permissions_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project_permission
      @project_permission = ProjectPermission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_permission_params
      params.require(:project_permission).permit(:user_id, :project_id, :permission)
    end

    def load_project
      @project = Project.find(params[:project_id])
    end
end
