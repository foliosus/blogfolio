class PagesController < ApplicationController

  before_filter :check_role_admin, :except => [:index_page, :show]
  cache_sweeper :page_sweeper, :only => [:create, :update]
  
  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.ordered.all
    
    @meta[:title] = 'Static page listing'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end
  
  # Show the real site home page
  def index_page
    unless fragment_exist?({:controller => :pages, :action => :show_index})
      # load data!
    end
    
    @meta[:title] = "Your website done right"
    @meta[:description] = "Foliosus Web Design LLC is a small web design studio in Portland, Oregon, that focuses on building custom websites that are easy to use by both site owners and visitors."
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])
    
    @meta[:title] = @page.name
    @meta[:description] = @page.description

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @page = Page.new
    
    @meta[:title] = 'New page'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
    
    @meta[:title] = 'Edit page'
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
        @meta[:title] = 'New page'
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
        @meta[:title] = 'New page'
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
