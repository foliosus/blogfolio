class AddCategoryToSchools < ActiveRecord::Migration
  def self.up
    add_column :schools, :category, :string
  end

  def self.down
    remove_column :school, :category
  end
end
