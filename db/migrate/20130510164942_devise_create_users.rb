class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      t.confirmable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :time, :unlock_in => 5.minutes
      # t.token_authenticatable

      t.timestamps

      t.string :fullname
      t.string :organization
      t.string :location
      t.string :about
      t.boolean :disable_email
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true
  end

  def self.down
    drop_table :users
  end
end
