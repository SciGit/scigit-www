class HomeController < ApplicationController
  # GET /
  # GET /
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { head :no_content }
    end
  end
end
