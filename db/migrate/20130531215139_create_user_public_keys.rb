class CreateUserPublicKeys < ActiveRecord::Migration
  def change
    create_table :user_public_keys do |t|
      t.references :user, index: true
      t.string :name
      t.string :key_type
      t.string :public_key
      t.string :comment

      t.timestamps
    end

    add_index :user_public_keys, :public_key, :unique => true
  end
end
