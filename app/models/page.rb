class Page < ActiveRecord::Base
  include ModelSecurity
  @permissions = {:create => :admin, :update => :admin, :delete => :admin}

  validates_presence_of [:name, :description, :content]
  validates_uniqueness_of :name
  validates_exclusion_of  :url, :in => 'index', :message => "can't be &quot;index&quot;"
  
  friendly_identifier :url, :identifier_column => :url
  
  named_scope :ordered, :order => 'name ASC'
  named_scope :contains, lambda{|text| {:conditions => ['name LIKE :s OR description LIKE :s OR content LIKE :s', {:s => "%#{text}%"}]} }
  
  # Returns the full path of the page
  def full_path
    "/#{url}"
  end
end
