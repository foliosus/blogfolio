class BulkMailer < ActionMailer::Base
  
  # Send a contact email internally, for response to the visitor
  def contact_email_for_oma(email)
    from        email.from
    recipients  (Rails.env.development? ? 'bmiller@foliosus.com' : Email::DEFAULT_EMAIL)
    subject     "[OMA] #{email.subject}"
    body        :content => email.body
  end
  
  # Send a copy of the contact email to the visitor, as a confirmation
  def contact_email_for_visitor(email)
    from        Email::DEFAULT_EMAIL
    recipients  email.from
    subject     "[OMA] #{email.subject}"
    body        :content => email.body  
  end
  
  # Send a bulk email to a single member
  def membership_email(member, email)
    from        email.from
    recipients  member.email
    subject     "[OMA] #{email.subject}"
    if member.is_a?(School)
      body      :text => email.body.gsub('%first_name', member.name).gsub('%last_name', member.name).gsub('%salutation', member.name)
    else
      body      :text => email.body.gsub('%first_name', member.first_name).gsub('%last_name', member.last_name).gsub('%salutation', member.first_name)
    end
  end
end
