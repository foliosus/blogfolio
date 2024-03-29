class PostsController < ApplicationController
  layout 'blog'

  before_filter   :login_required
  before_filter   :check_role_admin
  
  before_filter   :preload_validation_data
  before_filter   :preload_post, :only => [:show, :edit, :update, :destroy]
  
  cache_sweeper :post_sweeper, :only => [:create, :update, :destroy]
  
  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.published.reverse_chronological_order.all(:include => :categories)
    @drafts = Post.draft.reverse_chronological_order.all
    @meta[:title] = 'Blog posts'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @comment = @post.comments.new

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new
    @meta[:title] = "New post"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])
    
    respond_to do |format|
      if @post.save
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to(@post) }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        @meta[:title] = "New post"
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # GET /posts/1/edit
  def edit
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    params[:post][:category_ids] ||= []
    
    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to(@post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post.destroy
    flash[:notice] = 'Post destroyed.'

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def preload_validation_data
    @categories = Category.alphabetical.all
  end
  
  def preload_post
    @post = Post.find(params[:id])
    @meta[:title] = @post.title
    @meta[:description] = @post.summary
  end
end
