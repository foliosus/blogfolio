class AddNotes < ActiveRecord::Migration
  def self.up
    add_column :members, :notes, :text
    add_column :schools, :notes, :text
  end

  def self.down
    remove_column :members, :notes
    remove_column :schools, :notes
  end
end
