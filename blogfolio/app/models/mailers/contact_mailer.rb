class ContactMailer < ActionMailer::Base
  # layout 'email'
  
  # Send the contact confirmation message to the user
  def contact_to_customer(contact)
    recipients    contact.email
    from          Contact.default_email
    subject       "[Foliosus] #{contact.subject}"
    body          :contact => contact
  end
  
  # Send the contact message to foliosus
  def contact_to_foliosus(contact)
    recipients    Contact.default_email
    from          contact.email
    subject       "[Foliosus] #{contact.subject}"
    body          :contact => contact
  end

end
