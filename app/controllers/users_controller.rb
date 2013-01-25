class UsersController < ApplicationController
  skip_before_filter :authorize, only: [:new, :create, :validate]
 
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
    

  end

  # GET /users/1
  # GET /users/1.json
  def show
    
    @user = User.find_by_username(params[:id])
    
    filters = params[:filters] || []
    @contributions = []
    
    if !filters.empty?
      if filters.include? "experiments"
        @contributions += @user.experiments.search(params[:search])
      end
      
      if filters.include? "sessions"
         @contributions += @user.experiment_sessions.search(params[:search]) || []
      end
      
      if filters.include? "media"
         @contributions += @user.media_objects.search(params[:search]) || []
      end
      
    else
      @contributions += @user.experiments.search(params[:search])
      @contributions += @user.experiment_sessions.search(params[:search])
      @contributions += @user.media_objects.search(params[:search])
    end

    
   
    
    #Main List
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
end
