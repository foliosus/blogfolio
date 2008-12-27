class AddCategorySlug < ActiveRecord::Migration
  def self.up
    add_column :categories, :slug, :string, :limit => 25
  end

  def self.down
    remove_column :categories, :slug
  end
end
