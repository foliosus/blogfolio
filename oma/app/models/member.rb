class Member < ActiveRecord::Base
  include Addresses
  include MemberHelpers
  include ScopedSearch
  include Comparable
  
  belongs_to  :user, :dependent => :destroy
  has_many    :member_updates
  has_many    :memberships, :as => :member, :dependent => :delete_all
  has_many    :classifieds, :dependent => :delete_all
  belongs_to  :school
  has_many    :school_memberships, :through => :school, :source => :memberships
  
  validates_presence_of [:first_name, :last_name, :address, :city, :state, :zip]
  
  validates_uniqueness_of :user_id, :allow_nil => true
  validate    :email_is_unique
  
  before_create  :create_user_record

  include ModelSecurity
  @permissions = {:read => :member, :update => :secretary, :delete => :secretary}
  
  include ScopedSearch
  EXCLUSIVE_SCOPES = [:current, :lapsed, :applicants, :old, :retired, :not_retired]
  EXCLUDED_SCOPES = [:named]
  DEFAULT_SCOPES = [:current]
  
  CATEGORIES = [:new, :approved, :retired]

  # Currently active members
  named_scope :current, lambda {{
    :joins => "LEFT OUTER JOIN memberships ON ((memberships.member_id = members.id AND memberships.member_type = 'Member') OR (memberships.member_id = members.school_id AND memberships.member_type = 'School'))",
    :conditions => "memberships.year = #{Membership.current_year}",
    :order => 'last_name ASC, first_name ASC'
  }}
  
  # Expired members -- members from last year without a current membership record
  named_scope :lapsed, lambda {{
    :conditions => "members.category != 'retired'",
    :group => "members.id HAVING MAX(memberships.year) = #{Membership.current_year - 1}",
    :joins => "LEFT OUTER JOIN memberships ON ((memberships.member_id = members.id AND memberships.member_type = 'Member') OR (memberships.member_id = members.school_id AND memberships.member_type = 'School'))",
    :order => 'last_name ASC, first_name ASC'
  }}

  # New members applications requiring approval
  named_scope :applicants, :conditions => "category = 'new'", :order => 'created_at ASC'
  
  # Old members -- members without a current membership record who have lapsed from more than a year
  named_scope :old, lambda { {
    :conditions => "members.category != 'retired'",
    :group => "members.id HAVING MAX(memberships.year) < #{Membership.current_year - 1}",
    :joins => "LEFT OUTER JOIN memberships ON ((memberships.member_id = members.id AND memberships.member_type = 'Member') OR (memberships.member_id = members.school_id AND memberships.member_type = 'School'))",
    :order => 'last_name ASC, first_name ASC'
  }}
  
  # Members whose records have been retired
  named_scope :retired, :conditions => "category = 'retired'"
  
  # Members whose records have been retired
  named_scope :not_retired, :conditions => "category != 'retired'"
  
  # Members who are really the personal member associated with a member school
  named_scope :school_member, :conditions => 'school_id IS NOT NULL'
  
  # Members who specifically aren't associated with a member school
  named_scope :not_a_school_member, :conditions => 'school_id IS NULL'
  
  # Member name matching
  named_scope :named, lambda { |name| {
    :conditions => ['LOWER(first_name) LIKE :name OR LOWER(last_name) LIKE :name', {:name => "%#{name.downcase}%"}]
  }}
  
  # Return the list of available member categories
  def self.categories
    CATEGORIES
  end
  
  # Validates that the member's e-mail is unique, within the scope of the member & user records
  def email_is_unique
    valid = true
    if Member.count(:conditions => ['id != ? AND email = ?', self.id, self.email]) > 0
      valid = false
    else
      valid = false if User.count(:conditions => ['id != ? AND email = ?', self.user_id, self.email]) > 0
    end
    errors.add(:email, 'must be unique') unless valid
    return valid
  end
  
  # Create a user record for this member
  def create_user_record
    self.create_user(:email => self.email) if self.email?
  end
  
  # Allow sorting by name via Comparable
  def <=>(other)
    if self.last_name == other.last_name
      self.first_name <=> other.first_name
    else
      self.last_name <=> other.last_name
    end
  end
  
end
