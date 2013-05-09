class ProjectChangesController < ApplicationController
  # GET /project_changes
  # GET /project_changes.json
  def index
    @project_changes = ProjectChange.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @project_changes }
    end
  end

  # GET /project_changes/1
  # GET /project_changes/1.json
  def show
    @project_change = ProjectChange.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project_change }
    end
  end

  # GET /project_changes/new
  # GET /project_changes/new.json
  def new
    @project_change = ProjectChange.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project_change }
    end
  end

  # GET /project_changes/1/edit
  def edit
    @project_change = ProjectChange.find(params[:id])
  end

  # POST /project_changes
  # POST /project_changes.json
  def create
    @project_change = ProjectChange.new(params[:project_change])

    respond_to do |format|
      if @project_change.save
        format.html { redirect_to @project_change, notice: 'Project change was successfully created.' }
        format.json { render json: @project_change, status: :created, location: @project_change }
      else
        format.html { render action: "new" }
        format.json { render json: @project_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /project_changes/1
  # PUT /project_changes/1.json
  def update
    @project_change = ProjectChange.find(params[:id])

    respond_to do |format|
      if @project_change.update_attributes(params[:project_change])
        format.html { redirect_to @project_change, notice: 'Project change was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /project_changes/1
  # DELETE /project_changes/1.json
  def destroy
    @project_change = ProjectChange.find(params[:id])
    @project_change.destroy

    respond_to do |format|
      format.html { redirect_to project_changes_url }
      format.json { head :no_content }
    end
  end
end
