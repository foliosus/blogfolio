class AddLatLongToSchools < ActiveRecord::Migration
  def self.up
    change_table :schools do |t|
      t.decimal :latitude, :null => false, :precision => 11, :scale => 7
      t.decimal :longitude, :null => false, :precision => 11, :scale => 7
    end
  end

  def self.down
    change_table :schools do |t|
      t.remove :latitude
      t.remove :longitude
    end
  end
end
