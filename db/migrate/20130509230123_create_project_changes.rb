class CreateProjectChanges < ActiveRecord::Migration
  def change
    create_table :project_changes do |t|
      t.integer :user_id
      t.integer :project_id
      t.string :commit_msg
      t.string :commit_hash
      t.integer :commit_timestamp

      t.timestamps
    end
  end
end
