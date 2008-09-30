class ClassifiedsController < ApplicationController
  
  before_filter :check_role_member, :except => [:index, :show]
  
  # GET /classifieds
  # GET /classifieds.xml
  def index
    if params[:member_id]
      if User.current_user.can_update_classified?
        @classifieds = Member.find(params[:member_id]).classifieds.not_stale
      elsif User.current_user.can_create_classified? && User.current_user.member.id == params[:member_id].to_i
        @classifieds = User.current_user.member.classifieds.not_stale
      else
        raise NotAuthorized
        permission_denied && return
      end
    else
      @classifieds = Classified.not_stale.all
    end
    
    @meta_title = "Classifieds"
    @meta_description = "List of classified ads from the Oregon Montessori Association"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classifieds }
    end
  end

  # GET /classifieds/1
  # GET /classifieds/1.xml
  def show
    @classified = Classified.find(params[:id])
    
    @meta_title = @classified.title
    @meta_description = Markdown.new(@classified.description).to_html

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classified }
    end
  end

  # GET /classifieds/new
  # GET /classifieds/new.xml
  def new
    @classified = Classified.new(:member_id => @current_user.member.nil? ? nil : @current_user.member.id)
    
    @meta_title = 'New classified ad'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classified }
    end
  end

  # GET /classifieds/1/edit
  def edit
    @classified = Classified.find(params[:id])
    
    raise NotAuthorized unless @classified.can_be_edited_by?(@current_user)
    
    @meta_title = 'Edit classified'
  end

  # POST /classifieds
  # POST /classifieds.xml
  def create
    @classified = Classified.new(params[:classified])

    respond_to do |format|
      if @classified.save
        flash[:notice] = 'Classified was successfully created.'
        format.html { redirect_to(@classified) }
        format.xml  { render :xml => @classified, :status => :created, :location => @classified }
      else
        @meta_title = 'New classified ad'
        format.html { render :action => "new" }
        format.xml  { render :xml => @classified.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classifieds/1
  # PUT /classifieds/1.xml
  def update
    @classified = Classified.find(params[:id])

    raise NotAuthorized unless @classified.can_be_edited_by?(@current_user)

    respond_to do |format|
      if @classified.update_attributes(params[:classified])
        flash[:notice] = 'Classified was successfully updated.'
        format.html { redirect_to(@classified) }
        format.xml  { head :ok }
      else
        @meta_title = 'Edit classified'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classified.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classifieds/1
  # DELETE /classifieds/1.xml
  def destroy
    @classified = Classified.find(params[:id])

    raise NotAuthorized unless @classified.can_be_edited_by?(@current_user)

    @classified.destroy

    respond_to do |format|
      format.html { redirect_to(classifieds_url) }
      format.xml  { head :ok }
    end
  end
end
