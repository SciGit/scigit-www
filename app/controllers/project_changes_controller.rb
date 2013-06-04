class ProjectChangesController < ApplicationController
  before_action :set_project_change, only: [:show, :edit, :update, :destroy]
  #load_and_authorize_resource

  # GET /project_changes
  # GET /project_changes.json
  def index
    @project_changes = ProjectChange.all
  end

  # GET /project_changes/1
  # GET /project_changes/1.json
  def show
  end

  # GET /project_changes/new
  def new
    @project_change = ProjectChange.new
  end

  # GET /project_changes/1/edit
  def edit
  end

  # GET /project_changes/project/1/page/1
  # GET /project_changes/project/1/page/1.json
  def list
    # XXX: per() should use a config parameter instead of static value.
    @project_changes = ProjectChange.all_project_updates(Project.find(params[:project_id]), nil).page(params[:page]).per(10)
    render :layout => false
  end

  # GET /project_changes/project/1/changes/1/diff.json
  def diff
    diff = ProjectChange.diff(params[:id])
    respond_to do |format|
      format.json { render json: diff }
    end
  end

  # POST /project_changes
  # POST /project_changes.json
  def create
    @project_change = ProjectChange.new(project_change_params)

    respond_to do |format|
      if @project_change.save
        format.html { redirect_to @project_change, notice: 'Project change was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project_change }
      else
        format.html { render action: 'new' }
        format.json { render json: @project_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /project_changes/1
  # PATCH/PUT /project_changes/1.json
  def update
    respond_to do |format|
      if @project_change.update(project_change_params)
        format.html { redirect_to @project_change, notice: 'Project change was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /project_changes/1
  # DELETE /project_changes/1.json
  def destroy
    @project_change.destroy
    respond_to do |format|
      format.html { redirect_to project_changes_url }
      format.json { head :no_content }
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
