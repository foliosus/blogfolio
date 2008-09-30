class EmailsController < ApplicationController
  # Send a mass e-mail to the membership
  def index
    @email = Email.new(:from => Email::DEFAULT_EMAIL)
    count_members
    count_schools
    
    @meta_title = 'New membership email'
  end
  
  # For AJAX calls: return the count of members the selected scopes will return
  def calculate_member_counts
    count_members
    render :text => @members_count
  end
  
  # For AJAX calls: return the count of schools the selected scopes will return
  def calculate_school_counts
    count_schools
    render :text => @schools_count
  end
  
  # Send the bulk e-mail to the selected members
  def send_email
    @email = Email.new(params[:email].merge(:from => Email::DEFAULT_EMAIL))
    if @email.valid?
      members, current_member_scopes = Member.load_by_scoped_search(params[:member_scopes], params[:member_search])
      schools, current_school_scopes = School.load_by_scoped_search(params[:school_scopes], params[:school_search])
      recipients = members + schools
      
      exceptions = []
      recipients.in_groups_of(50) do |recipient_group| 
        logger.warn('mail server: ' + ActionMailer::Base.smtp_settings[:address])
        # Create an SMTP connection for this group of users 
        Net::SMTP.start(ActionMailer::Base.smtp_settings[:address],
                        ActionMailer::Base.smtp_settings[:port],
                        ActionMailer::Base.smtp_settings[:domain],
                        ActionMailer::Base.smtp_settings[:user_name],
                        ActionMailer::Base.smtp_settings[:password],
                        ActionMailer::Base.smtp_settings[:authentication]) do |smtp| 
          # Send the email to each user in this group 
          for recipient in recipient_group.compact
            unless recipient.email.blank? || recipient.respond_to?(:contact_by_email) && !recipient.contact_by_email
              begin
                logger.warn('sending email to ' + recipient.email)
                # Create the email message from our template
                email = BulkMailer.create_membership_email(recipient, @email) 
                # Send out each email 
                smtp.sendmail email.encoded, email.from, email.to
              rescue Exception => e 
                exceptions << ["member: #{recipient.inspect}", e]
                smtp.finish
                smtp.start
              end
            end #unless there is no e-mail
          end #for each recipient
        end #SMTP connection
      end #for each recipient group
      logger.warn("exceptions: #{exceptions.inspect}")
      flash[:notice] = "Message has been sent to #{recipients.length - exceptions.length} addresses."
      redirect_to :action => 'index'
    else
      @meta_title = 'New membership email'
      count_members
      count_schools
      render :action => :index
    end
  end
  
  def contact
    @email = Email.new()
    @meta_title = 'Contact OMA'
  end
  
  def send_contact
    @email = Email.new(params[:email])
    if @email.valid?
      BulkMailer.deliver_contact_email_for_oma(@email.dup)
      BulkMailer.deliver_contact_email_for_visitor(@email.dup)
      flash[:notice] = "Your request has been delivered to our staff, and a copy has been sent to the email address you provided.  You should hear from us soon!"
      redirect_to root_path
    else
      @meta_title = 'Contact OMA'
      render :action => :contact
    end
  end
  
  protected
  
  def count_members
    @member_count, @current_member_scopes = Member.count_by_scoped_search(params[:member_scopes], params[:member_search])
  end
  
  def count_schools
    @school_count, @current_school_scopes = School.count_by_scoped_search(params[:school_scopes], params[:school_search])
  end
end
