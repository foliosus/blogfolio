class Post < ActiveRecord::Base
  include ModelSecurity
  @permissions = {:create => :admin, :update => :admin, :delete => :admin}

  has_and_belongs_to_many   :categories, :order => 'name ASC'
  has_many                  :comments, :dependent => :destroy, :order => 'created_at ASC'
  
  validates_presence_of     [:title, :content]
  
  friendly_identifier :title, :identifier_column => :permalink
  
  STATUSES = ['draft', 'published']
  
  named_scope :reverse_chronological_order, :order => 'published_at DESC, posts.created_at DESC'
  named_scope :full_information, {:include => [:comments, :categories]}
  named_scope :published, {:conditions => {:status_id => STATUSES.index('published')}}
  named_scope :draft, {:conditions => {:status_id => STATUSES.index('draft')}}
  named_scope :status, lambda{|status| {:conditions => {:status_id => status}} }
  named_scope :contains, lambda{|text| {:conditions => ["title LIKE :s OR content LIKE :s", {:s => "%#{text}%"}]}}
  
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
    status_id = STATUSES.index('published')
    published_at = Time.now
  end
  
  # Set the post's status to 'published' and save the record
  def publish!
    publish
    save
  end
  
  # Set the post's status to 'draft'
  def unpublish
    status_id = STATUSES.index('draft')
    published_at = nil
  end
  
  # Return a summary of the post
  def summary
    self.content.gsub(/\r?\n\r?\n(.*)/m, '') # break after the first paragraph
  end
end
