class MakeMemberCategoriesString < ActiveRecord::Migration
  def self.up
    change_table :members do |t|
      t.remove :category_id
      t.string :category, :null => false, :default => 'new'
    end
    change_table :member_updates do |t|
      t.remove :category_id
      t.string :category, :null => false, :default => 'new'
    end
  end

  def self.down
    change_table :members do |t|
      t.remove :category
      t.integer :category_id, :null => false
    end
    change_table :member_updates do |t|
      t.remove :category
      t.integer :category_id, :null => false
    end
  end
end
