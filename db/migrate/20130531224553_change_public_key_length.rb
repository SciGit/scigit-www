class ChangePublicKeyLength < ActiveRecord::Migration
  def up
    remove_index :user_public_keys, :column => :public_key
    change_column :user_public_keys, :public_key, :string, :limit => 512
  end
  def down
    change_column :user_public_keys, :public_key, :string
    add_index :user_public_keys, :public_key, :unique => true
  end
end
