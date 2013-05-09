class CreateProjectPermissions < ActiveRecord::Migration
  def change
    create_table :project_permissions do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :permission

      t.timestamps
    end
  end
end
