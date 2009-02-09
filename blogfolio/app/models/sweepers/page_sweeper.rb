class PageSweeper < ActionController::Caching::Sweeper
  observe Page
  
  def after_create(page)
    ActionController::Routing::Routes.reload!
  end

  def after_save(page)
    expire_single(page)
  end
  
  def after_destroy(page)
    expire_single(page)
  end
  
  private
  
  def expire_single(page)
    expire_page("/#{page.url}")
  end
end
