class Membership < ActiveRecord::Base
  include Comparable
  
  ROLL_DATE = Date.new(Date.today.year, 8, 1)
  MEMBER_PAYMENT = 40
  SCHOOL_PAYMENT = 60
  
  belongs_to :member, :polymorphic => true
  
  validates_numericality_of :year, :greater_than_or_equal_to => 1990, :less_than_or_equal_to => 2020, :message => 'must be between 1990 and 2020'
  validates_numericality_of :payment, :greater_than_or_equal_to => 0
  
  include ModelSecurity
  @permissions = {:create => :secretary, :read => :secretary, :update => :secretary, :delete => :secretary}

  # Sort memberships, allowing new records to come first
  def <=>(other)
    if self.year?
      if other.year?
        self.year <=> other.year
      else
        1
      end
    else
      if other.year?
        -1
      else
        0
      end
    end
  end
  
  # Return the text of the year range this membership covers
  def year_range(separator = '-')
    "#{year}#{separator}#{year + 1}"
  end
  
  # Return the membership year based on the given year
  def self.current_year(date = Date.today)
    date < roll_date(date.year) ? date.year - 1 : date.year
  end
  
  # Return the roll date for a particular year
  def self.roll_date(year = Date.today.year)
    Date.new(year, ROLL_DATE.month, ROLL_DATE.day)
  end
end
