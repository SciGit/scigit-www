class AddEnabledToUserPublicKeys < ActiveRecord::Migration
  def change
    add_column :user_public_keys, :enabled, :int, :limit => 1
  end
end
