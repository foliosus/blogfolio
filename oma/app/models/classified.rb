# A classified ad posting. These must belong to a Member and have a lifespan of 3 months on the site.
class Classified < ActiveRecord::Base
  include ModelSecurity
  @permissions = {:create => :member, :update => :member, :delete => :secretary}

  belongs_to :member
  
  named_scope :recent, lambda{|*limit| {:order => "updated_at DESC", :limit => limit.flatten.first || 3} }
  named_scope :not_stale, :conditions => ['updated_at > ?', Date.today - 3.months]
  
  validates_presence_of [:title, :description, :contact]
  
  # Can this ad be edited by a particular user?
  def can_be_edited_by?(user)
    user.can_update_classified? || (user.member && user.member.id == self.member_id)
  end
end
