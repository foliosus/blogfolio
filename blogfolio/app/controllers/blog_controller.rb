class BlogController < ApplicationController
  before_filter   :prepare_secondary_content
  
  # Show recent posts
  def index
    @posts = Post.published.reverse_chronological_order.full_information.all(:limit => 10)
    @meta[:title] = 'Foliosus blog: recent posts'
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

    @meta[:title] = "Posts filed under #{@category.name}"
    
    @posts = @category.posts.published.all
    raise ActiveRecord::RecordNotFound unless @posts.length > 0
  end
  
  protected
  
    # Load the data necessary to render the secondary_content
    def prepare_secondary_content
      @categories = Category.with_posts.alphabetical.all
    end
end
