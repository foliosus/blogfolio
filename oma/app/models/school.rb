class School < ActiveRecord::Base
  include Addresses
  
  has_one   :member
  has_many  :memberships, :as => :member, :dependent => :delete_all
  
  validates_presence_of :latitude
  validates_presence_of :longitude
  
  before_save :geocode_address
  
  include ModelSecurity
  @permissions = {:create => :secretary, :update => :secretary, :delete => :secretary}

  include ScopedSearch
  EXCLUSIVE_SCOPES = [:current, :lapsed, :applicants]
  EXCLUDED_SCOPES = [:named]
  DEFAULT_SCOPES = [:current]

  # Currently active member schools
  named_scope :current, lambda {{
    :include => :memberships,
    :conditions => "memberships.year = #{Membership.current_year}",
    :order => 'state ASC, city ASC, name ASC'
  }}

  # Expired member schools -- members from last year without a current membership record
  named_scope :lapsed, lambda {{
    :group => "members.id HAVING max(memberships.year) < #{Membership.current_year}",
    :joins => 'LEFT OUTER JOIN memberships ON memberships.member_id = members.id',
    :order => 'state ASC, city ASC, name ASC'
  }}

  # New members applications requiring approval
  named_scope :applicants, :conditions => "category = 'new'", :order => 'created_at ASC'
  
  # Member school name matching
  named_scope :named, lambda { |name| {
    :conditions => ['LOWER(name) LIKE ?', "%#{name.downcase}%"]
  }}
  
  # The full address, all on one line, with fields separated by commas
  def one_line_address
    self.full_address.join(', ')
  end
  
  # Query Google & Yahoo for lat/long coordinates based on the <code>one_line_address</code>, if changes have been made
  def geocode_address
    if new_record? || address_changed? || address2_changed? || city_changed? || state_changed? || zip_changed?
      location = GeoKit::Geocoders::MultiGeocoder.geocode(one_line_address)
      if location.success
        self.latitude = location.lat
        self.longitude = location.lng
      else
        self.errors.add_to_base('Could not geocode the address')
      end
    end
  end

end
