ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.reset_password '/reset_password', :controller => 'users', :action => 'reset_password', :conditions => {:method => :post}

  map.resources :pages
  map.resources :users, :member => {:edit_password => :get, :update_password => :post, :reset_password => :post}
  map.resource :session
  map.resources :members, :member => {:destroy_membership => :post}, :collection => {:download => :get} do |member|
    member.resources :classifieds
  end
  map.destroy_membership 'members/destroy_membership/:id', :controller => :membership, :action => :destroy_membership, :conditions => {:method => :post}
  map.resources :news_items
  map.resources :events
  map.resources :classifieds
  map.resources :newsletters
  map.resources :member_updates
  map.resources :schools, :member => {:destroy_membership => :post}, :collection => {:download => :get}
  
  map.membership_email 'email', :controller => 'emails', :action => 'index'
  map.contact 'contact', :controller => 'emails', :action => 'contact'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"
  
  map.root  :controller => 'pages', :action => 'index_page'
  map.static_page ':id', :controller => 'pages', :action => 'show', :id => eval("/#{Page.all.collect{|p| p.url}.join('|')}/")
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
