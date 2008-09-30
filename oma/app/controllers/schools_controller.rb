class SchoolsController < ApplicationController
  include StreamCsv

  before_filter :check_role_secretary, :except => [:index, :show]

  # GET /schools
  # GET /schools.xml
  def index
    @search_params = params[:search]
    @schools, @current_scopes = School.load_by_scoped_search(params[:scopes], @search_params)
    
    @meta_title = 'OMA member schools'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schools }
    end
  end

  # GET /schools/1
  # GET /schools/1.xml
  def show
    @school = if @current_user && @current_user.has_role?(:secretary)
      School.find(params[:id], :include => :memberships)
    else
      School.current.find(params[:id])
    end
    
    @meta_title = @school.name

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @school }
    end
  end

  # GET /schools/new
  # GET /schools/new.xml
  def new
    @school = School.new
    @membership = @school.memberships.build(:payment => Membership::SCHOOL_PAYMENT)
    
    load_members_list if logged_in? && @current_user.can_create_school?
    
    @meta_title = logged_in? && @current_user.can_create_school? ? 'New member school' : 'School membership application'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @school }
    end
  end

  # GET /schools/1/edit
  def edit
    load_members_list
    @school = School.find(params[:id], :include => [:member, :memberships])
    @membership = @school.memberships.build(:payment => @school.memberships.empty? ? Membership::SCHOOL_PAYMENT : @school.memberships.last.payment)
    
    @meta_title = "Edit #{@school.name}"
  end

  # POST /schools
  # POST /schools.xml
  def create
    @school = School.new(params[:school])
    attach_input_membership

    respond_to do |format|
      if @school.save
        flash[:notice] = 'School was successfully created.'
        format.html { redirect_to(@school) }
        format.xml  { render :xml => @school, :status => :created, :location => @school }
      else
        load_members_list if logged_in? && @current_user.can_create_school
        @meta_title = logged_in? && @current_user.can_create_school? ? 'New member school' : 'School membership application'
        @membership = @school.memberships.select{|m| m.new_record? }.first
        format.html { render :action => "new" }
        format.xml  { render :xml => @school.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /schools/1
  # PUT /schools/1.xml
  def update
    @school = School.find(params[:id], :include => [:member, :memberships])
    attach_input_membership

    respond_to do |format|
      if @school.update_attributes(params[:school])
        flash[:notice] = 'School was successfully updated.'
        format.html { redirect_to(@school) }
        format.xml  { head :ok }
      else
        load_members_list
        @meta_title = "Edit #{@school.name}"
        @membership = @school.memberships.select{|m| m.new_record? }.first
        format.html { render :action => "edit" }
        format.xml  { render :xml => @school.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.xml
  def destroy
    @school = School.find(params[:id])
    name = @school.name
    @school.destroy
    
    flash[:notice] = "#{name} deleted"

    respond_to do |format|
      format.html { redirect_to(schools_url) }
      format.xml  { head :ok }
    end
  end

  # Destroy a membership record
  def destroy_membership
    @membership = Membership.find(params[:id], :include => :member)
    @school = @membership.member
    notice = "Membership record destroyed for #{@membership.year_range} for #{@school.name}"
    @membership.destroy
    flash[:notice] = notice
    
    respond_to do |format|
      format.html { redirect_to(edit_school_url(@school)) }
      format.xml  { head :ok }
    end
  end
  
  # Download a set of members' data as a CSV
  def download
    @schools, @current_scopes = School.load_by_scoped_search(params[:scopes], params[:search])
    
    stream_csv('schools.csv') do |csv|
      csv << ["name","address","address2", "city", "state", "zip", "phone", "email", "url"]
      @schools.each do |s|
        csv << [s.name, s.address, s.address2, s.city, s.state, s.zip, s.phone, s.email, s.url]
      end
    end
  end
  
  protected
  
  def load_members_list
    @members = Member.not_retired.find(:all, :order => 'last_name ASC, first_name ASC')
  end
  
  def attach_input_membership
    @school.memberships.build(params[:membership]) if params[:membership] && !params[:membership][:year].blank?
  end
end
