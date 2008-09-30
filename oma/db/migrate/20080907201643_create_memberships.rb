class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships, :force => true do |t|
      t.integer  :member_id, :null => false
      t.string   :member_type, :null => false
      t.integer  :year, :null => false
      t.integer  :payment, :default => 0,  :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :memberships
  end
end
