class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer       :post_id, :null => false
      t.string        :author, :limit => 60, :null => false
      t.string        :email, :limit => 60, :null => false
      t.string        :homepage, :limit => 60
      t.text          :body, :null => false
      t.timestamps
    end

    execute "ALTER TABLE comments ADD CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES posts(id)"

  end

  def self.down
    drop_table :comments
  end
end
