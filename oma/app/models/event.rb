class Event < ActiveRecord::Base
  include ModelSecurity
  @permissions = {:create => :secretary, :update => :secretary, :delete => :secretary}
  
  validates_presence_of [:name, :description, :location, :the_date]
  
  named_scope :ordered, :conditions => ['the_date >= ?', Date.today], :order => 'the_date ASC'
  named_scope :limited, lambda{|*limit| {:limit => limit.flatten.first || 3} }
end
