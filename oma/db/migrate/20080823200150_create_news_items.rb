class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string  :name, :null => false
      t.text    :description, :null => false
      t.string  :location
      t.date    :the_date, :null => false
      t.string  :the_time, :null => false
      t.string  :contact

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
