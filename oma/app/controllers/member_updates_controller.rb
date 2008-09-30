class MemberUpdatesController < ApplicationController
  before_filter :check_role_member, :only => [:new, :create]
  before_filter :check_role_secretary, :except => [:new, :create]

  # GET /member_updates
  # GET /member_updates.xml
  def index
    @member_updates = MemberUpdate.find(:all, :include => :member)
    @member_updates.sort{|a,b| a.member <=> b.member}
    
    @meta_title = 'Unprocessed member record updates'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @member_updates }
    end
  end

  # GET /member_updates/new
  # GET /member_updates/new.xml
  def new
    @member_update = @current_user.member.member_updates.new
    @member_update.populate_from_member_attributes
    
    @meta_title = 'Please update your information'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @member_update }
    end
  end

  # GET /member_updates/1/edit
  def edit
    @member_update = MemberUpdate.find(params[:id])
    @member = @current_user.member
    @meta_title = 'Review member update'
  end

  # POST /member_updates
  # POST /member_updates.xml
  def create
    @member_update = MemberUpdate.new(params[:member_update])
    @member_update.member = @current_user.member

    respond_to do |format|
      if @member_update.save
        flash[:notice] = 'Your updated information will be reviewed, and the update should appear online within a few days.'
        format.html { redirect_to(root_url) }
        format.xml  { render :xml => @member_update, :status => :created, :location => @member_update }
      else
        @meta_title = 'Please update your information'
        format.html { render :action => "new" }
        format.xml  { render :xml => @member_update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /member_updates/1
  # PUT /member_updates/1.xml
  def update
    @member_update = MemberUpdate.find(params[:id])
    @member_update.update_attributes(params[:member_update])
    
    @member = @current_user.member
    logger.warn("** @member_update: #{@member_update.inspect}")
    logger.warn("** fields_for_updating: #{@member_update.fields_for_updating_member.inspect}")

    respond_to do |format|
      if @member.update_attributes(@member_update.fields_for_updating_member) 
        @member_update.destroy
        flash[:notice] = 'Member update was successfully processed.  The new data are now live.'
        format.html { redirect_to(member_updates_url) }
        format.xml  { head :ok }
      else
        @meta_title = 'Review member update'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member_update.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /member_updates/1
  # DELETE /member_updates/1.xml
  def destroy
    @member_update = MemberUpdate.find(params[:id])
    @member_update.destroy

    respond_to do |format|
      format.html { redirect_to(member_updates_url) }
      format.xml  { head :ok }
    end
  end
end
