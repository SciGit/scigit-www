class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  load_and_authorize_resource :only => [:show]

  rescue_from CanCan::AccessDenied do |exception|
    @topic = 'Error'
    @errors = exception.message
    render 'shared/message'
  end

  # GET /projects
  # GET /projects.json
  def index
    @my_projects = Project.all_manager_of(current_user)
    @subscriptions = Project.all_subscribed_to(current_user)
  end

  # GET /projects/public
  # GET /projects/public.json
  def public
    @public_projects = Project.all_public
    @featured_projects = []
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @members = ProjectPermission.all_project_managers(@project)
    @numSubscribers = ProjectPermission.all_project_subscribers(@project).count
    @numMembers = ProjectPermission.all_project_members(@project).count
    @changes = ProjectChange.all_project_updates(@project)
  end

  # GET /projects/new
  def new
    @project = Project.new

    respond_to do |format|
      format.html { render action: 'new', :layout => nil }
      format.json { head :no_content }
    end
  end

  # GET /projects/1/edit
  def edit
  end

  # GET /project_changes/project/1/doc/:doc_hash/path
  # Gets a file contained inside a word document.
  def doc
    @project = Project.find(params[:id])
    filename = params[:file]
    unless params[:format].nil?
      filename += '.' + params[:format]
    end
    file = @project.get_doc_file(params[:doc_hash], filename)
    if file.nil?
      render :text => 'Not found', :status => :not_found
    else
      options = {:disposition => 'inline'}
      if type = Mime::Type.lookup_by_extension(params[:format])
        options[:type] = type
      end
      send_data file, options
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    @project_permission = ProjectPermission.new(:user => current_user, :project => @project, :permission => ProjectPermission::OWNER)

    respond_to do |format|
      if @project.save and @project_permission.save
        begin
          require 'scigit/thrift_client'
          SciGit::ThriftClient.new.createRepository(@project.id)

          @notice = "Project #{@project.name} was created successfully."
          format.html { redirect_to @project, notice: @notice }
          format.json { render }
        rescue
          @project.destroy
          @project_permission.destroy

          format.html { render action: 'new' }
          format.json { render json: 'Database error. Please try again later.', status: :unprocessable_entity }
        end
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :description, :public)
    end
end
