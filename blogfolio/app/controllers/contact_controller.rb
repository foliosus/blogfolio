# Take in and process contact form requests
class ContactController < ApplicationController
  # Both provide the form, and process & send the e-mails when the contact form is submitted
  def index
    @contact = Contact.new(params[:contact])
    
    @meta[:title] = 'Contact Foliosus Web Design'

    #FIXME Flash ain't showing!
    flash.now[:notice] = "Showing a message"
    flash.now[:warning] = "Showing a warning"
    flash.now[:error] = "Showing an error"
    logger.warn("** flash: #{flash.inspect}")
    
    if params[:contact] && @contact.valid?
      ContactMailer.deliver_contact_to_foliosus(@contact)
      ContactMailer.deliver_contact_to_customer(@contact)
      flash[:notice] = 'Your message has been sent, and a confirmation email is on its way to the email you provided. We will get back to you soon. Thank you for your interest in Foliosus Web Design.'
      redirect_to root_path
    end
  end
end
