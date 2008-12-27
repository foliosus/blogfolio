class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.string      :name, :limit => 25, :null => false
      t.timestamps
    end
    
    create_table :categories_posts do |t|
      t.integer     :category_id, :null => false
      t.integer     :post_id, :null => false
      t.timestamps
    end

    execute "ALTER TABLE categories_posts DROP PRIMARY KEY, DROP id, ADD PRIMARY KEY (category_id, post_id)"
    
    Category.create(:name => 'Rails')
    Category.create(:name => 'Browsers')
    Category.create(:name => 'Food')
    
  end

  def self.down
    drop_table :categories
    drop_table :categories_posts
  end
end
