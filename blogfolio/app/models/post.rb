class Post < ActiveRecord::Base
  has_and_belongs_to_many   :categories, :order => 'name ASC'
  has_many                  :comments
  
  validates_presence_of     [:title, :content]
  
  friendly_identifier :title, :identifier_column => :permalink
  
  STATUSES = ['draft', 'published']
  
  named_scope :reverse_chronological_order, :order => 'posts.created_at DESC'
  named_scope :full_information, {:include => [:comments, :categories]}
  named_scope :published, {:conditions => {:status_id => STATUSES.index('published')}}
  named_scope :status, lambda{|status| {:conditions => {:status_id => status}} }

  # Return the status as text, taken from Post::STATUSES
  def status
    STATUSES[self.status_id || 0]
  end
  
  # Return an array with the names of all of the categories the Post belongs to
  def categories_list
    self.categories.collect{|c| c.name}
  end
  
  # Set the post's status to 'published'
  def publish
    self.status_id = STATUSES.index('published')
  end
  
  # Set the post's status to 'published' and save the record
  def publish!
    self.publish
    self.save
  end
  
  # Return a summary of the post
  def summary
    self.content.gsub(/\r?\n\r?\n(.*)/m, '') # break after the first paragraph
  end
  
  # List all posts
  def self.list(options = {})
    status = options[:status] || STATUSES.index(options.delete(:status).to_s) || STATUSES.index('published')
    options.reverse_merge!(:order => 'posts.created_at desc', :include => [:comments, :categories], :conditions => ['status_id = ?', status])
    self.find(:all, options)
  end
end
