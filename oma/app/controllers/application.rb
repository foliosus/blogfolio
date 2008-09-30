# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b86c0545f804d1fa31779fa63d73ad27'
  
  filter_parameter_logging :password, :password_confirmation
  
  # Ensure that we load the current user's info, if they exist
  before_filter :current_user
  
  def rescue_action_in_public(exception)
    case exception
    when NotAuthorized
      permission_denied
    else
      #TODO render the 500 error here
      raise exception
    end
  end
  
  private
    def user_not_authorized
      
    end
end
