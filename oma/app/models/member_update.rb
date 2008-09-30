class MemberUpdate < ActiveRecord::Base
  include MemberHelpers
  
  has_one :user, :through => :member
  belongs_to :member
  
  include ModelSecurity
  @permissions = {:create => :member, :read => :secretary, :update => :secretary, :delete => :secretary}
  
  OVERLAP_FIELDS = [:first_name, :last_name, :phone, :email, :address, :address2, :city, :state, :zip, :volunteer, :speaker, :category]
  
  before_save :strip_unmodified_fields
  
  # Load the data in from the parent member record
  def populate_from_member_attributes
    OVERLAP_FIELDS.each do |field|
      self.write_attribute(field, self.member.send(field))
    end
  end
  
  # Return the values for updating the parent member record
  def fields_for_updating_member
    fields = {}
    OVERLAP_FIELDS.each do |field|
      fields[field] = self.read_attribute(field) if self.send("#{field}?".to_sym)
    end
    [:speaker, :volunteer].each do |field|
      fields[field] = self.read_attribute(field)
    end
    return fields
  end
  
  # Only store the fields that have been modified
  def strip_unmodified_fields
    OVERLAP_FIELDS.each do |field|
      self.write_attribute(field, nil) if self.read_attribute(field) == self.member.send(field)
    end
  end
  
  # Override the MemberHelpers email= method
  def email=(new_email)
    write_attribute(:email, new_email ? new_email.downcase : nil)
  end
end
