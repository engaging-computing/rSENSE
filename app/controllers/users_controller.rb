require 'base64'

class UsersController < ApplicationController
  skip_before_filter :authorize, only: [:new, :create, :validate]
 
  include ActionView::Helpers::DateHelper
  include ApplicationHelper
 
  # GET /users
  # GET /users.json
  def index
    #Main List
    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end
    
    if !params[:per_page].nil?
        pagesize = params[:per_page]
    else
        pagesize = 10;
    end
    
    @users = User.search(params[:search]).paginate(page: params[:page], per_page: pagesize).order("created_at #{sort}")
    
    respond_to do |format|
      format.html { render status: :ok }
      format.json { render json: @users.map {|u| u.to_hash(false)}, status: :ok }
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
    #Grab the User
    @user = User.find_by_username(params[:id])
    
    if(@user == nil || @user.hidden)
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/404.html", :status => :not_found }
        format.json { render json: {}, status: :unprocessable_entity }
      end
    end
    
    recur = params.key?(:recur) ? params[:recur].to_bool : false
    show_hidden = @cur_user.id == @user.id
          
    respond_to do |format|
      format.html { render status: :ok }
      format.json { render json: @user.to_hash(recur, show_hidden), status: :ok }
    end
  end
  
  # GET /users/1/contributions
  # GET /users/1.json
  def contributions
    
    @user = User.find_by_username(params[:id])
    
    #See if we are only looking for specific contributions
    @filters = params[:filters].to_s.downcase
    @filters.tr!(' ', '_')
    
    if @filters == "all"
      @filters = [ "projects", "data_sets", "visualizations", "media", "tutorials" ]
    end
    
    if params[:page_size].nil?
      page_size = 10
    else
      page_size = params[:page_size].to_i
    end
    
    show_hidden = (@cur_user.id == @user.id) || can_admin?(@user)
    
    #Only grab the contributions we are currently interested in
    if !@filters.empty?
      if @filters.include? "projects"
        @projects = @user.projects.search(params[:search], show_hidden)
      end
      
      if @filters.include? "data_sets"
        @dataSets = @user.data_sets.search(params[:search], show_hidden)
      end
      
      if @filters.include? "media"
        @mediaObjects = @user.media_objects.search(params[:search], show_hidden)
      end

      if @filters.include? "visualizations"
        @visualizations = @user.visualizations.search(params[:search], show_hidden)
      end
      
      if @filters.include? "tutorials"
        @tutorials = @user.tutorials.search(params[:search], show_hidden)
      end
    else
      if !@user.try(:projects).nil?
        @projects = @user.projects.search(params[:search], show_hidden)
      end
      if !@user.try(:data_sets).nil?
        @dataSets = @user.data_sets.search(params[:search], show_hidden)
      end
      if !@user.try(:media_objects).nil?
        @mediaObjects = @user.media_objects.search(params[:search], show_hidden)
      end
      if !@user.try(:visualizations).nil?
        @visualizations = @user.visualizations.search(params[:search], show_hidden)
      end
      if !@user.try(:tutorials).nil?
        @tutorials = @user.tutorials.search(params[:search], show_hidden)
      end
    end

    @contributions = @projects.to_a + @dataSets.to_a + @mediaObjects.to_a + @visualizations.to_a + @tutorials.to_a
    
    #Set up the sort order
    if !params[:sort].nil?
      sort = params[:sort]
    else
      sort = "DESC"
    end
    
    if sort=="ASC"
      @contributions.sort! {|a,b| a.created_at <=> b.created_at} 
    else
      @contributions.sort! {|a,b| b.created_at <=> a.created_at}
    end
    
    page = params[:page].to_i
    
    if @contributions.length == 0
      @totalPages = 0
    else
      @totalPages = (@contributions.length/page_size).ceil + 1
    end  

    @lastPage = false
    if page+1 == @totalPages.to_i
      @lastPage = true
    end
    
    @contributions = @contributions[page*page_size..(page*page_size)+(page_size - 1)]
    
    if params[:template].nil?
  
      respond_to do |format|
        format.html { render partial: "display_contributions" }
      end

    else

      respond_to do |format|
        format.html { render partial: params[:template] }
      end

    end

  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user.to_hash(false) }
    end
  end
  
  # GET /users/1/edit
  def edit
    @user = User.find_by_username(params[:id])
  end
  
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user.to_hash(false), status: :created, location: @user }
      else
        flash[:debug] = @user.errors.inspect
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find_by_username(params[:id])
    editUpdate = params[:user]
    hideUpdate = editUpdate.extract_keys!([:hidden])
    success = false
    
    #EDIT REQUEST
    if can_edit?(@user) 
      success = @user.update_attributes(editUpdate)
    end
    
    #HIDE REQUEST
    if can_hide?(@user) 
      success = @user.update_attributes(hideUpdate)
    end
    
    respond_to do |format|
      if success
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        format.html { render "public/404.html" }
        format.json { render json: @user.errors.full_messages(), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find_by_username(params[:id])
    
    if can_delete?(@user)
      
      if @cur_user.id == @user.id
        session[:user_id] = nil
      end
      
      @user.projects.each do |p|
        p.hidden = true
        p.save
      end
      @user.media_objects.each do |m|
        m.destroy
      end
      @user.visualizations.each do |v|
        v.hidden = true
        v.save
      end
      @user.data_sets.each do |d|
        d.hidden = true
        d.save
      end
      @user.tutorials.each do |t|
        t.hidden = true
        t.save
      end
      
      @user.hidden = true
      @user.email =  "#{Time.now().to_i}@deleted.org"
      @user.username =  "#{Time.now().to_i}"
      @user.save
      
      respond_to do |format|
        format.html { redirect_to users_url}
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        flash[:debug] = "Failed can_delete?"
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end

  # GET /users/validate/:key
  def validate
    key = Base64.decode64(params[:key])
    
    @user = User.find_by_validation_key(key)

    if @user == nil or params[:key].blank?
      render "public/404.html"
    else

      @user.validated = true
      @user.save

      render action: "validate"
    end
  end

  # GET /users/verify
  def verify
    respond_to do |format|
      if @cur_user == nil
        format.json {render json: "{}", status: :unauthorized}
      else
        format.json {render json: "{}", status: :ok}
      end
    end
  end
end
