class PagesController < ApplicationController

  before_filter :check_role_secretary, :except => [:index_page, :show]
  
  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.ordered.all
    
    @meta_title = 'Static page listing'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end
  
  # Show the real site home page
  def index_page
    unless fragment_exist?({:controller => :pages, :action => :show_index})
      @classifieds = Classified.recent(3).all
      @events = Event.ordered.limited(3).all
      @news_items = NewsItem.ordered.limited(3).all
    end
    
    @meta_title = "Oregon Montessori Association"
    #TODO Get the real meta description here
    @meta_description = "The Oregon Montessori Association's mission is to advance the Montessori educational movement in Oregon.  OMA provides resources for Montessori educators and parents, and serves to connect the Montessori community in the Pacific Northwest."

    render :layout => 'index'
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])
    
    @meta_title = @page.name
    @meta_description = @page.description

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = Page.new
    
    @meta_title = 'New page'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
    
    @meta_title = 'Edit page'
  end

  # POST /pages
  # POST /pages.xml
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        ActionController::Routing::Routes.reload!
        flash[:notice] = "&quot;#{@page.name}&quot; created."
        format.html { redirect_to(pages_url) }
        format.xml  { render :xml => @page, :status => :created, :location => @page }
      else
        @meta_title = 'New page'
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        ActionController::Routing::Routes.reload!
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to(@page) }
        format.xml  { head :ok }
      else
        @meta_title = 'New page'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    ActionController::Routing::Routes.reload!
    flash[:notice] = 'Page deleted'

    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end
end
