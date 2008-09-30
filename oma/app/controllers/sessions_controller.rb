# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
    @meta_title = 'Member login'
  end

  # Log in a user with their login and password: create a session for them.
  def create
    logout_keeping_session!
    user = User.authenticate(params[:email], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      flash[:notice] = "Logged in successfully"
      if user.force_password_reset? && action_name.to_sym != :update_password
        store_location
        flash[:error] = "Your current password is single-use. Please change it to a permanent password."
        @user = user
        render :template => 'users/edit_password'
      else
        redirect_back_or_default('/')
      end
    else
      note_failed_signin
      @email = session[:email] = params[:email]
      @remember_me = params[:remember_me]
      @meta_title  = 'Member login'
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end
  
protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in #{params[:email].blank? ? 'without an email' : "as '" + params[:email] + "'"}. If you're a new member, don't forget to activate your account using the link we sent you in your welcome email."
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
