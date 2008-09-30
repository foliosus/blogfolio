class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.date :the_date

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end
