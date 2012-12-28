class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string      :url, :null => false, :limit => 255
      t.string      :name, :null => false
      t.string      :description, :limit => 255, :null => false
      t.text        :content
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
