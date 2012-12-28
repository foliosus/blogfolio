class AddSecondaryContentToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :secondary_content, :text
  end

  def self.down
    remove_column :pages, :secondary_content
  end
end
