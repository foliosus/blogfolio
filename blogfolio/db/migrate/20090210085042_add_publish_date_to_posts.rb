class AddPublishDateToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :published_at, :datetime
    
    # Set the published_at time to the creation time for all currently published posts
    Post.published.each{|post| post.update_attributes(:published_at => post.created_at) }
  end

  def self.down
    remove_column :posts, :published_at, :datetime
  end
end
