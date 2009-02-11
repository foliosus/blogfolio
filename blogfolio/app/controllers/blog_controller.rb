class BlogController < ApplicationController
  before_filter   :prepare_secondary_content, :except => :rss
  
  skip_before_filter :load_photos, :only => :rss
  
  # Show recent posts
  def index
    @posts = Post.published.reverse_chronological_order.paginate(:include => :comments, :page => params[:page], :per_page => 10)
    @meta[:title] = 'Foliosus blog: recent posts'
  end
  
  # RSS feed
  def rss
    @posts = Post.published.reverse_chronological_order.full_information.all(:limit => 10)
    respond_to do |format|
      format.xml
    end
  end
  
  # Show a single post, with comments form
  def show
    @post = Post.published.full_information.find(params[:id])

    @meta[:description] = @post.summary
    @meta[:title] = @post.title
  end
  
  # Show posts for a single category
  def category
    @category = Category.find(params[:category])

    @meta[:title] = "Posts in \"#{@category.name.downcase}\""
    
    @posts = @category.posts.published.reverse_chronological_order.all
    raise ActiveRecord::RecordNotFound unless @posts.length > 0
  end
  
  # Number to show per page of results
  def per_page
    10
  end
  
  protected
  
    # Load the data necessary to render the secondary_content
    def prepare_secondary_content
      @categories = Category.with_posts.alphabetical.all
    end
end
