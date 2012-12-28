class Category < ActiveRecord::Base
  include ModelSecurity
  @permissions = {:create => :admin, :update => :admin, :delete => :admin}

  has_and_belongs_to_many   :posts
  has_and_belongs_to_many   :published_posts, :class_name => 'Post', :conditions => "status_id = #{Post::STATUSES.index('published')}", :order => 'posts.created_at DESC'
  
  friendly_identifier :name, :identifier_column => :slug
  
  named_scope :with_posts, {:select => 'categories.*, count(categories_posts.category_id) AS post_count',
    :joins => 'INNER JOIN categories_posts ON categories.id = categories_posts.category_id',
    :group => 'categories.id'}
  named_scope :alphabetical, :order => 'categories.name ASC'
  
end
