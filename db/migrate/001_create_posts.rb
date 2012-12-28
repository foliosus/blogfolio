class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string      :title, :length => 120, :null => false
      t.text        :content
      t.string      :permalink, :length => 200
      t.integer     :status_id, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
