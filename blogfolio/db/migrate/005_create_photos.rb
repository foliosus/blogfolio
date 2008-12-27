class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string      :title, :limit => 250, :null => false
      t.text        :caption
      t.string      :filename, :limit => 250, :null => false
      t.integer     :width, :null => false
      t.integer     :height, :null => false
      t.string      :content_type, :limit => 100
      t.datetime    :image_date, :null => false
      t.string      :keywords, :limit => 250
      t.integer     :aperture
      t.string      :focal_length, :limit => 10
      t.string      :shutter_speed, :limit => 8
      t.integer     :speed
      t.integer     :focal_length
      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
