class UsersController < ApplicationController
  
  before_filter :login_required, :only => [:edit_password, :update_password]
  before_filter :check_role_secretary, :except => [:edit_password, :update_password, :reset_password, :activate]
  
  # Show the form for creating a new user
  def new
    @user = User.new(:role => :none)
    @members = Member.current.all
    
    @meta_title = "Create a new user"
  end
  
  # Create a new user (triggering the activation e-mail)
  def create
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      @members = Member.current.all
      render :action => 'new'
    end
  end
  
  # Activate a new user, using the code they received in their activation e-mail
  def activate
    if params[:id].blank?
      flash[:error] = "You must have an activation number in order to activate your account. Please check your activation e-mail."
      redirect_to root_url
      return
    end
    
    user = User.find_by_activation_code(params[:id])
    case
      when user && user.active?
        flash[:warning] = "You've already activated your account.  Please log in."
        redirect_to login_url
      when user && !user.active?
        user.activate!
        flash[:notice] = "Signup complete! Please sign in to continue."
        redirect_to login_url
      else
        flash[:error]  = "We couldn't find a user with that activation code &mdash; please double check your activation email to find your activation code."
        redirect_back_or_default('/')
    end
  end
  
  # Allow a user to edit their password
  def edit_password
    raise NotAuthorized unless @current_user.id == params[:id].to_i
    
    @meta_title = 'Change your password'
  end
  
  # Process the password update
  def update_password
    raise NotAuthorized unless @current_user.id == params[:id].to_i
    
    @current_user.force_password_reset = false
    
    if @current_user.update_attributes(params[:user])
      redirect_back_or_default(root_path)
    else
      @meta_title = 'Change your password'
      render :action => :edit_password
    end
  end
  
  # Reset the user's password
  def reset_password
    email = params[:id] || session[:email]
    if email.blank?
      flash[:error] = "You must provide an e-mail address in order to reset an account"
    else
      user = params[:id] ? User.find(params[:id], :include => :member) : User.find_by_email(email, :include => :member)
      if user.reset_password!
        flash[:notice] = "User account has been reset, and a new activation email has been sent to the address we have on record."
      else
        flash[:error] = "There was an error, and the user account couldn't be reset. Please contact the site administrator."
      end
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "The email address you provided (#{email}) couldn't be found. Sorry!"
  ensure
    redirect_back_or_default (logged_in? && !user.blank? ? root_url : login_url)
  end
  
  
end
