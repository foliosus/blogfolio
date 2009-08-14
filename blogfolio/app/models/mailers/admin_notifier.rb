class AdminNotifier < ActionMailer::Base
  
  # A new comment!
  def comment_creation_email(comment)
    recipients    Contact.default_email
    from          Contact.default_email
    subject       "[Foliosus] A new comment has been posted"
    body          :comment => comment
  end

end
