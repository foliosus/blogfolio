module MemberHelpers
  # Returns the member's full name.  If the optional parameter is <code>true</code>, the last name is output first
  def full_name(last_name_first = false)
    if last_name_first
      "#{last_name}, #{first_name}"
    else
      "#{first_name} #{last_name}"
    end
  end

  # Ensure that the e-mail address is synched with the user record
  def email=(new_email)
    self.user.email = new_email unless self.user.nil?
    write_attribute(:email, new_email ? new_email.downcase : nil)
  end
end