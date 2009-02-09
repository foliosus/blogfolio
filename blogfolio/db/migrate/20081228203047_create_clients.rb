class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :name, :limit => 80, :null => false
      t.string :slug, :limit => 80, :null => false
      t.text :teaser, :null => false
      t.text :content, :null => false
      t.string :url, :limit => 120

      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end
