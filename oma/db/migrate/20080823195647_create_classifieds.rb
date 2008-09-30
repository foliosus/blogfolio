class CreateClassifieds < ActiveRecord::Migration
  def self.up
    create_table :classifieds do |t|
      t.string  :title, :null => false
      t.text    :description, :null => false
      t.string  :url
      t.string  :email
      t.string  :phone, :limit => 10
      t.text    :contact, :null => false
      t.integer :member_id
      t.timestamps
    end
  end

  def self.down
    drop_table :classifieds
  end
end
