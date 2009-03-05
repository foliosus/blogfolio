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
    9.times{|n| expire_page(blog_path(:page => n + 1)) }
    9.times{|n| expire_page(blog_category_path(:page => n + 1)) }
    expire_page(rss_path)
    expire_page(atom_path)
  end
end
