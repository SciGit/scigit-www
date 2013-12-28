class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :only => [:show, :edit, :files, :update, :destroy]

  rescue_from CanCan::AccessDenied do |exception|
    @topic = 'Error'
    @errors = exception.message
    render 'shared/message'
  end

  # GET /projects
  # GET /projects.json
  def index
    project_permissions = ProjectPermission.where(:user => current_user)
    @my_projects = project_permissions.select{ |pp| pp.user.can? :manage, pp.project }.map(&:project)
    @subscriptions = project_permissions.select{ |pp| pp.user.can?([:subscribed, :update], pp.project) }.map(&:project)
  end

  # GET /projects/public
  # GET /projects/public.json
  def public
    @public_projects = Project.where(:public => true)
    @featured_projects = []
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    project_permissions = ProjectPermission.where(:project => @project)
    @changes = ProjectChange.all_project_updates(@project)
    @change = @changes.first
    @file_listing = @project.get_file_listing
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
    project_permissions = ProjectPermission.where(:project => @project)
    @permissions = project_permissions.select{ |pp| pp.user.can? :read, pp.project }
  end

  # GET /project_changes/project/1/doc/:doc_hash/path
  # Gets a file contained inside a word document.
  def doc
    filename = params[:file]
    # Only allow access to images for now.
    if !filename.starts_with?('images/')
      render :text => 'Not found', :status => :not_found
      return
    end
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

  # GET /projects/:id/files?path=..
  def files
    if params[:change]
      @change = ProjectChange.find(params[:change])
    else
      @change = ProjectChange.all_project_updates(@project).first
    end
    @path = params[:path] || ''
    @prev_path = @path.split('/')[0..-2].join('/')
    type = @project.get_file_type(@path, @change)
    if type.nil?
      return head :not_found
    elsif type == 'blob'
      @file_data = @project.get_file(@path, @change)
      if @file_data.index("\0")
        @file_data = 0
      end
    else
      @file_listing = @project.get_file_listing(@path, @change)
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

          format.html { redirect_to @project, notice: @notice }
          format.json { render json: {
            :redirect => project_path(@project.id),
            :notice => "Project #{@project.name} was created successfully.",
          } }
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
        format.json { render json: {
          :notice => "#{@project.name} has been updated.",
        } }
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
    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name, :description, :public)
    end
end
