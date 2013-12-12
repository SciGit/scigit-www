class ProjectChangesController < ApplicationController
  before_action :set_project_change, only: [:show, :edit, :update, :destroy]
  #load_and_authorize_resource

  # GET /project_changes
  # GET /project_changes.json
  def index
    @project = Project.find(params[:project_id])
    authorize! :read, @project

    @file = params[:file]
    if @file
      @project_changes = @project.get_file_changes(@file)
    else
      @project_changes = ProjectChange.all_project_updates(@project)
    end
    @selected_change = @project_changes.first
  end

  # GET /project_changes/1
  # GET /project_changes/1.json
  def show
    index

    if @file
      @selected_change = @project_changes.bsearch { |change| change.id <= params[:id].to_i }
    else
      @selected_change = ProjectChange.find(params[:id])
    end

    if !@selected_change || @project.id != @selected_change.project_id
      return head :bad_request
    end

    authorize! :read, @selected_change
    render action: 'index'
  end

  # GET /project_changes/project/1/page/1
  # GET /project_changes/project/1/page/1.json
  def list
    @project = Project.find(params[:project_id])
    authorize! :read, @project

    # XXX: per() should use a config parameter instead of static value.
    @project_changes = ProjectChange.all_project_updates(@project, nil).page(params[:page]).per(10)
    render :layout => false
  end

  # GET /project_changes/project/1/changes/1/diff.json
  def diff
    @project_change = ProjectChange.find(params[:id])
    authorize! :read, @project_change

    @diff = @project_change.diff(params[:file] || '')
    @fileTypes = {
      :createdFiles => {:name => 'Created', :label => 'success'},
      :deletedFiles => {:name => 'Deleted', :label => 'danger'},
      :updatedFiles => {:name => 'Updated', :label => 'primary'},
    }
    respond_to do |format|
      format.json {
        render json: {
          :files_html => (render_to_string action: 'diff/files.html', :layout => false),
          :diff_viewer_html => (render_to_string action: 'diff/viewer.html', :layout => false),
        }
      }
    end
  end

  # GET /project_changes/project/1/changes/1/file/:filename
  def file
    @project_change = ProjectChange.find(params[:id])
    authorize! :read, @project_change

    filename = params[:file]
    unless params[:format].nil?
      filename += '.' + params[:format]
    end
    file = @project_change.get_file(filename)
    if file.nil?
      render :text => 'Not found', :status => :not_found
    else
      send_data(file, :filename => filename)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project_change
      @project_change = ProjectChange.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_change_params
      params.require(:project_change).permit(:user_id, :project_id, :commit_msg, :commit_hash, :commit_timestamp)
    end
end
