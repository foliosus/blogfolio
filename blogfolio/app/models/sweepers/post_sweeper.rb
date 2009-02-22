class PostSweeper < ActionController::Caching::Sweeper
  observe Post
  
  def after_create(post)
    expire_single_post(post)
  end
  
  def after_save(post)
    expire_single_post(post)
  end
  
  def after_destroy(post)
    expire_single_post(post)
  end
  
  private
  
  def expire_single_post(post)
    expire_page(blog_path)
    expire_page(rss_path)
    expire_page(atom_path)
  end
end
