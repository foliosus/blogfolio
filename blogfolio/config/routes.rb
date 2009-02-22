ActionController::Routing::Routes.draw do |map|
  map.resources :posts, :has_many => :comments, :shallow => true
  map.resources :pages
  map.resources :clients, :as => 'portfolio'
  map.resources :users
  map.resources :categories

  map.resource :session
  
  map.search '/search', :controller => 'search', :action => 'index'

  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  map.with_options(:controller => 'blog') do |m|
    m.blog '/blog/:page', :action => 'index', :page => 1, :requirements => {:page => /\d/}
    m.with_options(:action => 'feed') do |n|
      n.with_options(:format => 'rss') do |o|
        o.rss '/blog/rss'
        o.legacy_rss '/feed'
      end
      n.with_options(:format => 'atom') do |o|
        o.atom '/blog/atom'
        o.legacy_atom '/feed/atom'
      end
    end
    m.blog_post '/blog/:id', :action => 'show'
    m.blog_category '/blog/category/:category', :action => 'category'
    m.legacy_blog_category '/category/:category', :action => 'category'
    m.dated_blog_post '/blog/:year/:month/:day/:id',  :controller => 'blog', :action => 'show',
                                                      :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/
    m.legacy_dated_blog_post '/:year/:month/:day/:id',:controller => 'blog', :action => 'show',
                                                      :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/
  end
  
  map.contact '/contact', :controller => 'contact', :action => 'index'

  map.root :controller => 'pages', :action => 'index_page'
  
  map.static_page '/:id', :controller => 'pages', :action => 'show', :id => eval("/#{Page.all.collect{|p| p.url}.join('|')}/")
  
  # Install the default routes as the lowest priority.
  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
