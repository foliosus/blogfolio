class NewsItemsController < ApplicationController

  before_filter :check_role_secretary, :except => [:index, :show]

  # GET /news_item
  # GET /news_item.xml
  def index
    @news_items = NewsItem.ordered
    
    @meta_title = 'OMA news'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @news_item }
    end
  end

  # GET /news_item/1
  # GET /news_item/1.xml
  def show
    @news_item = NewsItem.find(params[:id])
    @meta_title = @news_item.name
    @meta_descriptino = @news_item.description

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @news_item }
    end
  end

  # GET /news_item/new
  # GET /news_item/new.xml
  def new
    @news_item = NewsItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @news_item }
    end
  end

  # GET /news_item/1/edit
  def edit
    @news_item = NewsItem.find(params[:id])
  end

  # POST /news_item
  # POST /news_item.xml
  def create
    @news_item = NewsItem.new(params[:news_item])

    respond_to do |format|
      if @news_item.save
        flash[:notice] = 'News was successfully created.'
        format.html { redirect_to(@news_item) }
        format.xml  { render :xml => @news_item, :status => :created, :location => @news_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /news_item/1
  # PUT /news_item/1.xml
  def update
    @news_item = NewsItem.find(params[:id])

    respond_to do |format|
      if @news_item.update_attributes(params[:news_item])
        flash[:notice] = 'News was successfully updated.'
        format.html { redirect_to(@news_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /news_item/1
  # DELETE /news_item/1.xml
  def destroy
    @news_item = NewsItem.find(params[:id])
    @news_item.destroy

    respond_to do |format|
      format.html { redirect_to(news_items_url) }
      format.xml  { head :ok }
    end
  end
end
