class ClientSweeper < ActionController::Caching::Sweeper
  observe Client
  
  def after_create(client)
    expire_single_client(client)
  end
  
  def after_save(client)
    expire_single_client(client)
  end
  
  def after_destroy(client)
    expire_single_client(client)
  end
  
  private
  
  def expire_single_client(client)
    expire_page(:controller => :clients, :action => :show, :id => client.slug)
    expire_page(:controller => :clients, :action => :index)
    expire_page(:controller => :pages, :action => :index_page)
  end
end
