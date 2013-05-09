class ProjectPermissionsController < ApplicationController
  # GET /project_permissions
  # GET /project_permissions.json
  def index
    @project_permissions = ProjectPermission.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @project_permissions }
    end
  end

  # GET /project_permissions/1
  # GET /project_permissions/1.json
  def show
    @project_permission = ProjectPermission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project_permission }
    end
  end

  # GET /project_permissions/new
  # GET /project_permissions/new.json
  def new
    @project_permission = ProjectPermission.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project_permission }
    end
  end

  # GET /project_permissions/1/edit
  def edit
    @project_permission = ProjectPermission.find(params[:id])
  end

  # POST /project_permissions
  # POST /project_permissions.json
  def create
    @project_permission = ProjectPermission.new(params[:project_permission])

    respond_to do |format|
      if @project_permission.save
        format.html { redirect_to @project_permission, notice: 'Project permission was successfully created.' }
        format.json { render json: @project_permission, status: :created, location: @project_permission }
      else
        format.html { render action: "new" }
        format.json { render json: @project_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /project_permissions/1
  # PUT /project_permissions/1.json
  def update
    @project_permission = ProjectPermission.find(params[:id])

    respond_to do |format|
      if @project_permission.update_attributes(params[:project_permission])
        format.html { redirect_to @project_permission, notice: 'Project permission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project_permission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /project_permissions/1
  # DELETE /project_permissions/1.json
  def destroy
    @project_permission = ProjectPermission.find(params[:id])
    @project_permission.destroy

    respond_to do |format|
      format.html { redirect_to project_permissions_url }
      format.json { head :no_content }
    end
  end
end
