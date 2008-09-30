class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :email,                     :string, :limit => 100, :null => false
      t.column :crypted_password,          :string, :limit => 40, :null => false
      t.column :salt,                      :string, :limit => 40, :null => false
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.column :activation_code,           :string, :limit => 40
      t.column :activated_at,              :datetime
      t.column :role,                      :string, :limit => 12
      t.timestamps
    end
    add_index :users, :email, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
