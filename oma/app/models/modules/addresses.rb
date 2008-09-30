module Addresses
  def included(base)
    base.class_eval do
      validates_presence_of :address
      validates_presence_of :city
      validates_inclusion_of :state, :in => US_STATES.collect{|s| s[1]}
      validates_presence_of :zip
    end
  end
  
  US_STATES = [
    [ "Alabama", "AL" ], 
    [ "Alaska", "AK" ], 
    [ "Arizona", "AZ" ], 
    [ "Arkansas", "AR" ], 
  	[ "California", "CA" ], 
  	[ "Colorado", "CO" ], 
  	[ "Connecticut", "CT" ], 
  	[ "Delaware", "DE" ], 
  	[ "District Of Columbia", "DC" ], 
  	[ "Florida", "FL" ], 
  	[ "Georgia", "GA" ], 
  	[ "Hawaii", "HI" ], 
  	[ "Idaho", "ID" ], 
  	[ "Illinois", "IL" ], 
  	[ "Indiana", "IN" ], 
  	[ "Iowa", "IA" ], 
  	[ "Kansas", "KS" ], 
  	[ "Kentucky", "KY" ], 
  	[ "Louisiana", "LA" ], 
  	[ "Maine", "ME" ], 
  	[ "Maryland", "MD" ], 
  	[ "Massachusetts", "MA" ], 
  	[ "Michigan", "MI" ], 
  	[ "Minnesota", "MN" ], 
  	[ "Mississippi", "MS" ], 
  	[ "Missouri", "MO" ], 
  	[ "Montana", "MT" ], 
  	[ "Nebraska", "NE" ], 
  	[ "Nevada", "NV" ], 
  	[ "New Hampshire", "NH" ], 
  	[ "New Jersey", "NJ" ], 
  	[ "New Mexico", "NM" ], 
  	[ "New York", "NY" ], 
  	[ "North Carolina", "NC" ], 
  	[ "North Dakota", "ND" ], 
  	[ "Ohio", "OH" ], 
  	[ "Oklahoma", "OK" ], 
  	[ "Oregon", "OR" ], 
  	[ "Pennsylvania", "PA" ], 
  	[ "Rhode Island", "RI" ], 
  	[ "South Carolina", "SC" ], 
  	[ "South Dakota", "SD" ], 
  	[ "Tennessee", "TN" ], 
  	[ "Texas", "TX" ], 
  	[ "Utah", "UT" ], 
  	[ "Vermont", "VT" ], 
  	[ "Virginia", "VA" ], 
  	[ "Washington", "WA" ], 
  	[ "West Virginia", "WV" ], 
  	[ "Wisconsin", "WI" ], 
  	[ "Wyoming", "WY" ]
  ]
  
  # Return the address as an array, with one "line" per array entry
  def full_address
    [self.address, self.address2, "#{self.city}, #{self.state} #{self.zip}"].select{|a| !a.blank?}.compact
  end
  
  # Return the phone number, properly formatted
  def phone
    the_number = read_attribute(:phone)
    the_number ? "(#{the_number[0..2]}) #{the_number[3..5]}-#{the_number[6..-1]}" : nil
  end
  
  # Assign a phone number, regardless of the format of the incoming string
  def phone=(new_number)
    if new_number
      write_attribute(:phone, new_number.gsub(/[^0-9]/, ''))
    else
      write_attribute(:phone, nil)
    end
  end
end