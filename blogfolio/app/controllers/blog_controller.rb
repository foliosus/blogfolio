class BlogController < ApplicationController
  before_filter   :prepare_secondary_content, :except => :feed
  
  skip_before_filter :load_photos, :only => :feed
  skip_before_filter :set_meta_data, :only => :feed
  
  caches_page :index
  caches_page :feed
  caches_page :category
  
  # Show recent posts
  def index
    @posts = Post.published.full_information.reverse_chronological_order.paginate(:page => params[:page], :per_page => 10)
    @meta[:title] = 'Foliosus blog: recent posts'
  end
  
  # RSS feed
  def feed
    @posts = Post.published.reverse_chronological_order.full_information.all(:limit => 10)
    respond_to do |format|
      format.rss
      format.atom
    end
  end
  
  # Show a single post, with comments form
  def show
    @post = Post.published.full_information.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @post

    @meta[:description] = @post.summary
    @meta[:title] = @post.title
  end
  
  # Show posts for a single category
  def category
    raise ActiveRecord::RecordNotFound if params[:category] == 'admin' # This is a fix for Yahoo Slurp suckage
    @category = Category.find(params[:category])

    @meta[:title] = "Posts in \"#{@category.name.downcase}\""
    
    @posts = @category.posts.published.reverse_chronological_order.paginate(:page => params[:page], :per_page => 10)
  end
  
  protected
  
    # Load the data necessary to render the secondary_content
    def prepare_secondary_content
      @categories = Category.with_posts.alphabetical.all
    end
end
