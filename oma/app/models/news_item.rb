class NewsItem < ActiveRecord::Base
  include ModelSecurity
  @permissions = {:create => :secretary, :update => :secretary, :delete => :secretary}
  
  validates_presence_of [:name, :description, :the_date]
  
  named_scope :limited, lambda {|*the_limit| {:limit => the_limit.flatten.first || 3} }
  named_scope :ordered, :order => "the_date DESC"
end
