class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.string  :name, :null => false, :limit => 255
      t.text    :description, :null => false
      t.date    :the_date, :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :news_items
  end
end
