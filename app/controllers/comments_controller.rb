class CommentsController < ApplicationController
  before_filter   :login_required, :except => [:create]
  before_filter   :check_role_admin, :except => [:create]
  

  # GET /comments
  # GET /comments.xml
  def index
    @comments = Comment.find(:all, :include => :post, :order => 'comments.created_at DESC')
    @meta[:title] = 'Comments'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.xml
  def show
    @comment = Comment.find(params[:id])
    @meta[:title] = "Comment from #{@comment.author}"

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/new
  # GET /comments/new.xml
  def new
    @comment = Comment.new
    @meta[:title] = 'New comment'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /comments/1/edit
  def edit
    @comment = Comment.find(params[:id])
    @post = @comment.post
    @meta[:title] = "Comment from #{@comment.author}"
  end

  # POST /comments
  # POST /comments.xml
  def create
    @comment = Comment.new(params[:comment])
    @comment.post = Post.find(params[:post_id], :include => [:comments, :categories])

    respond_to do |format|
      if @comment.save
        flash[:notice] = 'Comment was successfully created.'
        format.html { redirect_to(blog_post_path(@comment.post)) }
        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
      else
        @post = @comment.post
        @meta[:title] = @post.title
        format.html { render :template => 'posts/show', :layout => 'blog' }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = 'Comment was successfully updated.'
        format.html { redirect_to(@comment) }
        format.xml  { head :ok }
      else
        @meta[:title] = "Comment from #{@comment.author}"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    flash[:notice] = "Comment destroyed"

    respond_to do |format|
      format.html { redirect_to(comments_url) }
      format.xml  { head :ok }
    end
  end
end
