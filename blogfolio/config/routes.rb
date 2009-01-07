ActionController::Routing::Routes.draw do |map|
  map.resources :posts, :has_many => :comments, :shallow => true
  map.resources :photos
  map.resources :pages
  map.resources :clients, :as => 'portfolio'
  map.resources :users
  map.resources :categories

  map.resource :session

  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.blog '/blog', :controller => 'blog'
  map.dated_blog_post '/blog/:year/:month/:day/:id', :controller => 'blog', :action => 'show',
                                                     :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/
  map.blog_post '/blog/:id', :controller => 'blog', :action => 'show'
  map.blog_category '/blog/category/:category', :controller => 'blog', :action => 'category'
  
  map.contact 'contact', :controller => 'contact', :action => 'index'

  map.root :controller => 'pages', :action => 'index_page'
  
  map.static_page ':id', :controller => 'pages', :action => 'show', :id => eval("/#{Page.all.collect{|p| p.url}.join('|')}/")

  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
