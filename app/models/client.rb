class Client < ActiveRecord::Base
  include ModelSecurity
  @permissions = {:create => :admin, :update => :admin, :delete => :admin}
  
  validates_presence_of [:name, :slug, :teaser, :content]
  validates_format_of :url, :with => /https?:\/\//, :message => 'should start with "http://"', :allow_nil => true
  friendly_identifier :name, :identifier_column => :slug
  
  named_scope :alphabetical, :order => 'name ASC'
  named_scope :reverse_chronological_order, :order => 'updated_at DESC'
  
  PATH = '/clients'
  
  # Thumbnail file name
  def thumb_filename
    "#{slug}_thumb.jpg"
  end
  
  # Full size image file name
  def image_filename
    "#{slug}.jpg"
  end
  
  # Path to the thumbnail
  def thumb_path
    "#{PATH}/#{thumb_filename}"
  end
  
  # Path to the full-size image
  def image_path
    "#{PATH}/#{image_filename}"
  end
  
  # Does the Client have a testimonial?
  def has_testimonial?
    testimonial_text?
  end
  
  # Who is the author of the testimonial? If none exists, use the Client name.
  def testimonial_author
    read_attribute(:testimonial_author) || name
  end
end
