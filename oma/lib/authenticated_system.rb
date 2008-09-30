module AuthenticatedSystem
  
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end

    # Accesses the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
    end

    # Store the given user id in the session.
    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @current_user = new_user || false
      logger.debug("Current user: #{@current_user.email} (#{@current_user.id}: #{@current_user.role})")
      User.current_user = @current_user
    end

    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    #
    def authorized?(action = action_name, resource = nil)
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          flash[:error] = "You must login in order to access that function"
          redirect_to new_session_path
        end
        # format.any doesn't work in rails version < http://dev.rubyonrails.org/changeset/8987
        # Add any other API formats here.  Some browsers send Accept: */* and 
        # trigger the 'format.any' block incorrectly.
        format.any(:json, :xml) do
          request_http_basic_authentication 'Web Password'
        end
      end
    end
    
    # Respond to a user who is trying to get access to something they shouldn't see
    #
    # After issuing a flash error, redirect the user to where they came from
    def permission_denied
      respond_to do |format|
        format.html do
          logger.warn("User #{current_user.email} (#{current_user.id}: #{current_user.role? ? current_user.role : 'no role'}) tried to load #{request.request_uri}, but was denied permission")
          flash[:error] = "You don't have permission to do that"
          redirect_back_or_default('/')
        end
        format.xml do
          headers["Status"] = "Unauthorized"
          render :text => "You don't have permission to complete this action", :status => 401
        end
      end
    end
    
    # Verify that the user has the specified role
    def check_role(role)
      unless logged_in? && current_user.has_role?(role)
        if logged_in?
          permission_denied
        else
          access_denied
        end
      end
    end
    
    # Create methods like "check_role_member" and "check_role_secretary"
    def method_missing_with_roles(method_called, *args, &block)
      match = method_called.to_s.match(/^check_role_(\w+)$/)
      if match && User::ROLES.include?(match[1].to_sym)
        check_role(match[1])
      else
        method_missing_without_roles(method_called, *args, &block)
      end
    end
    alias_method_chain  :method_missing, :roles
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri unless request.request_uri.match(/\/session/)
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.  Set an appropriately modified
    #   after_filter :store_location, :only => [:index, :new, :show, :edit]
    # for any controller you want to be bounce-backable.
    def redirect_back_or_default(default = request.env['HTTP_REFERER'])
      redirect_to(session[:return_to] || default, :protocol => request.env['HTTPS'] ? 'https' : 'http')
      session[:return_to] = nil
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?, :authorized? if base.respond_to? :helper_method
    end

    #
    # Login
    #

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = User.find_by_id(session[:user_id], :include => :member) if session[:user_id]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |login, password|
        self.current_user = User.authenticate(login, password)
      end
    end
    
    #
    # Logout
    #

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    # for the paranoid: we _should_ be storing user_token = hash(cookie_token, request IP)
    def login_from_cookie
      user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        self.current_user = user
        handle_remember_cookie! false # freshen cookie token (keeping date)
        self.current_user
      end
    end

    # This is ususally what you want; resetting the session willy-nilly wreaks
    # havoc with forgery protection, and is only strictly necessary on login.
    # However, **all session state variables should be unset here**.
    def logout_keeping_session!
      # Kill server-side auth cookie
      @current_user.forget_me if @current_user.is_a? User
      @current_user = false     # not logged in, and don't do it for me
      kill_remember_cookie!     # Kill client-side auth cookie
      session[:user_id] = nil   # keeps the session but kill our variable
      # explicitly kill any other session variables you set
    end

    # The session should only be reset at the tail end of a form POST --
    # otherwise the request forgery protection fails. It's only really necessary
    # when you cross quarantine (logged-out to logged-in).
    def logout_killing_session!
      logout_keeping_session!
      reset_session
    end
    
    #
    # Remember_me Tokens
    #
    # Cookies shouldn't be allowed to persist past their freshness date,
    # and they should be changed at each login

    # Cookies shouldn't be allowed to persist past their freshness date,
    # and they should be changed at each login

    def valid_remember_cookie?
      return nil unless @current_user
      (@current_user.remember_token?) && 
        (cookies[:auth_token] == @current_user.remember_token)
    end
    
    # Refresh the cookie auth token if it exists, create it otherwise
    def handle_remember_cookie!(new_cookie_flag)
      return unless @current_user
      case
      when valid_remember_cookie? then @current_user.refresh_token # keeping same expiry date
      when new_cookie_flag        then @current_user.remember_me 
      else                             @current_user.forget_me
      end
      send_remember_cookie!
    end
  
    def kill_remember_cookie!
      cookies.delete :auth_token
    end
    
    def send_remember_cookie!
      cookies[:auth_token] = {
        :value   => @current_user.remember_token,
        :expires => @current_user.remember_token_expires_at }
    end

end
