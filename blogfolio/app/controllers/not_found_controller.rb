# Used for grabbing unmatched routes, and showing a 404 page
class NotFoundController < ApplicationController
  # Render the shared 404 error page
  def index
    render :template => 'shared/404', :status => 404
  end
end
