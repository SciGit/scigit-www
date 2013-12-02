class AddPublicToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :public, :boolean, :after => :description
  end
end
