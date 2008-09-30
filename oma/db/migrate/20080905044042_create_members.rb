class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.string      :first_name, :limit => 40, :null => false
      t.string      :last_name, :limit => 40, :null => false
      t.string      :phone, :limit => 10
      t.string      :email, :limit => 60
      t.string      :address, :limit => 60, :null => false
      t.string      :address2, :limit => 60
      t.string      :city, :limit => 25, :null => false
      t.string      :state, :limit => 2, :null => false, :default => 'OR'
      t.string      :zip, :limit => 5, :null => false
      t.boolean     :volunteer, :null => false, :default => false
      t.boolean     :speaker, :null => false, :default => false
      t.integer     :category_id, :null => false
      t.integer     :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
