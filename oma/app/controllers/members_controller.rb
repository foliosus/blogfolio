class MembersController < ApplicationController
  include StreamCsv
  
  before_filter :check_role_member, :only => [:index, :show]
  before_filter :check_role_secretary, :except => [:index, :show, :new]
  
  # GET /members
  # GET /members.xml
  def index
    @search_params = params[:search]
    @members, @current_scopes = Member.load_by_scoped_search(params[:scopes], @search_params)
    
    @meta_title = 'Membership list'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @members }
    end
  end

  # GET /members/1
  # GET /members/1.xml
  def show
    @member = if @current_user && @current_user.has_role?(:secretary)
      Member.find(params[:id], :include => [:memberships, :user])
    else
      Member.current.find(params[:id])
    end
    
    @meta_title = @member.full_name

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end

  # GET /members/new
  # GET /members/new.xml
  def new
    @member = Member.new
    @membership = @member.memberships.build(:payment => Membership::MEMBER_PAYMENT)
    
    preload_schools if logged_in? && @current_user.can_create_member?
    @meta_title = logged_in? && @current_user.has_role?(:secretary) ? 'New member' : 'Membership application'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @member }
    end
  end

  # GET /members/1/edit
  def edit
    @member = Member.find(params[:id], :include => [:memberships, :user])
    @membership = @member.memberships.build(:payment => @member.memberships.empty? ? Membership::MEMBER_PAYMENT : @member.memberships.last.payment)
    preload_schools
    
    @meta_title = "Edit #{@member.full_name}"
  end

  # POST /members
  # POST /members.xml
  def create
    @member = Member.new(params[:member])
    attach_input_membership
    
    respond_to do |format|
      if @member.save
        flash[:notice] = 'Member was successfully created. '
        flash[:notice] += 'A user account was created for the new member, and they have been sent an activation email.' unless @member.user.nil?
        format.html { redirect_to(@member) }
        format.xml  { render :xml => @member, :status => :created, :location => @member }
      else
        preload_schools if logged_in && @current_user.can_create_member?
        @meta_title = logged_in? && @current_user.has_role?(:secretary) ? 'New member' : 'Membership application'
        @membership = @member.memberships.select{|m| m.new_record? }.first
        format.html { render :action => "new" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.xml
  def update
    @member = Member.find(params[:id], :include => [:memberships, :user])
    attach_input_membership

    respond_to do |format|
      if @member.update_attributes(params[:member])
        @member.user.update_attributes(:role => params[:role])
        flash[:notice] = 'Member was successfully updated.'
        format.html { redirect_to(@member) }
        format.xml  { head :ok }
      else
        preload_schools
        @meta_title = "Edit #{@member.full_name}"
        @membership = @member.memberships.select{|m| m.new_record? }.first
        format.html { render :action => "edit" }
        format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.xml
  def destroy
    @member = Member.find(params[:id])
    name = @member.full_name
    @member.destroy
    
    flash[:notice] = "#{name} deleted. Their user account has also been removed."

    respond_to do |format|
      format.html { redirect_to(members_url) }
      format.xml  { head :ok }
    end
  end
  
  # Destroy a membership record
  def destroy_membership
    @membership = Membership.find(params[:id], :include => :member)
    @member = @membership.member
    notice = "Membership record destroyed for #{@membership.year_range} for #{@member.full_name}"
    @membership.destroy
    flash[:notice] = notice
    
    respond_to do |format|
      format.html { redirect_to(edit_member_url(@member)) }
      format.xml  { head :ok }
    end
  end
  
  # Download a set of members' data as a CSV
  def download
    @members, @current_scopes = Member.load_by_scoped_search(params[:scopes], params[:search])
    
    stream_csv('members.csv') do |csv|
      csv << ["first_name","last_name","address","address2", "city", "state", "zip", "phone", "email"]
      @members.each do |m|
        csv << [m.first_name, m.last_name, m.address, m.address2, m.city, m.state, m.zip, m.phone, m.email]
      end
    end
  end
  
  protected
  
  # Preload the schools validation list
  def preload_schools
    @schools = School.current.find(:all, :order => 'name ASC')
  end
  
  # When pulling in data from the form, ensure that the membership record (if any) gets properly attached to the member record
  def attach_input_membership
    @member.memberships.build(params[:membership]) if params[:membership] && !params[:membership][:year].blank?
  end
  
  # Send out a CSV file as an HTTP stream
  def stream_csv(filename = "data.csv", &block)
    #this is required if you want this to work with IE		
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain"
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      headers['Expires'] = "0"
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end

    render :text => Proc.new { |response, output|
      csv = FasterCSV.new(output, :row_sep => "\r\n") 
      yield csv
    }
  end
end
