# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  include AuthenticatedSystem
  
  before_filter   :set_meta_data
  before_filter   :load_photos

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '6f4840a76e3e0583f9ddd22ea0323ec1'
  
  protected
    
    # Set the metadata for the page. This provides a default, but can/should be overriden in child controllers.
    def set_meta_data
      @meta = {:title => "#{self.controller_name.capitalize} #{self.action_name.downcase}",
               :description => "Foliosus Web Design LLC provides quality custom websites."}
    end
    
    # Load photos for sidebar
    def load_photos(options = {})
      logger.warn("** Loading Flickr photos")
      options = options.reverse_merge(:user_id => '88016824@N00', :per_page => 8)
      @flickr = Flickr.new("#{RAILS_ROOT}/config/flickr_fu.yml")
      @plant_photo = @flickr.photos.search(options.merge(:tags => 'plants', :per_page => 8, :page => 2)).photos.compact.rand
      @photos = @flickr.photos.search(options)
    end
end
