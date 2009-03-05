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
    post.categories.each do |category|
      9.times{|n| expire_page(blog_category_path(:category => category, :page => n + 1)) }
    end
    expire_page(rss_path)
    expire_page(atom_path)
  end
end
