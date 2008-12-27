class PageSweeper < ActionController::Caching::Sweeper
  observe Page
  
  def after_create(page)
    ActionController::Routing::Routes.reload!
  end

  def after_save(page)
    expire_fragment({:controller => :pages, :action => :show, :id => page.id})
  end
end
