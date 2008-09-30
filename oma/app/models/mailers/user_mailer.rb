class UserMailer < ActionMailer::Base
  # Send a "please activate your account" e-mail to a new user
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
    @body[:url]  = "#{root_url}users/activate/#{user.activation_code}"
  end
  
  # Send a "you've been activated" e-mail to a newly activated user
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = root_url
  end
  
  protected
    # Default e-mail settings
    def setup_email(user)
      @recipients  = user.email
      @from        = Email::DEFAULT_EMAIL
      @subject     = "[OMA] "
      @body[:user] = user
    end
end
