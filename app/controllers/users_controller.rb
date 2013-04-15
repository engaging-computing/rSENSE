class UsersController < ApplicationController
  skip_before_filter :authorize, only: [:new, :create, :validate]
 
  include ActionView::Helpers::DateHelper
 
  # GET /users
  # GET /users.json
  def index
    #Main List
    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end
    
    @users = User.search(params[:search]).paginate(page: params[:page], per_page: 8).order("created_at #{sort}")
    
    jsonObjects = []
    
    @users.each do |user|
      
      newJsonObject = {}
      
      newJsonObject["ownerName"]      = "#{user.name}"      
      newJsonObject["username"]          = user.username
      newJsonObject["timeAgoInWords"] = time_ago_in_words(user.created_at)
      newJsonObject["createdAt"]      = user.created_at.strftime("%B %d, %Y")
      newJsonObject["ownerPath"]      = user_path(user)
      newJsonObject["userGravatar"] = "http://www.gravatar.com/avatar.php?gravatar_id=#{Digest::MD5::hexdigest(user.email)}"
      if (newJsonObject["userGravatar"] == "http://www.gravatar.com/avatar.php?gravatar_id=d41d8cd98f00b204e9800998ecf8427e")
        newJsonObject["userGravatar"] = "NULL"
      end
      
      jsonObjects = jsonObjects << newJsonObject
      
    end
    
    respond_to do |format|
      format.html { render status: :ok }
      format.json { render json: jsonObjects, status: :ok }
    end

  end

  # GET /users/1
  # GET /users/1.json
  def show
    #Grab the User
    @user = User.find_by_username(params[:id])
    
    #See if we are only looking for specific contributions
    @filters = params[:filters] || []
    @contributions = []
    
    #Only grab the contributions we are currently interested in
    if !@filters.empty?
      if @filters.include? "projects"
        @contributions += @user.projects.search(params[:search])
      end
      
      if @filters.include? "data_sets"
         @contributions += @user.data_sets.search(params[:search]) || []
      end
      
      if @filters.include? "media"
         @contributions += @user.media_objects.search(params[:search]) || []
      end

      if @filters.include? "visualizations"
        @contributions += @user.visualizations.search(params[:search]) || []
      end
    else
      if !@user.try(:projects).nil?
        @contributions += @user.try(:projects).search(params[:search])
      end
      if !@user.try(:data_sets).nil?
        @contributions += @user.try(:data_sets).search(params[:search])
      end
      if !@user.try(:media_objects).nil?
        @contributions += @user.try(:media_objects).search(params[:search])
      end
      if !@user.try(:visualizations).nil?
        @contributions += @user.try(:visualizations).search(params[:search])
      end
    end

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
    
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
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
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find_by_username(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find_by_username(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # GET /users/validate/:key
  def validate
    @user = User.find_by_validation_key(params[:key])

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
        format.json {render json: "", status: :unauthorized}
      else
        format.json {render json: "", status: :ok}
      end
    end
  end
end
