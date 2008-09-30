class AddForceResetToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :force_password_reset, :boolean, :default => true
  end

  def self.down
    remove_column :users, :force_password_reset
  end
end
