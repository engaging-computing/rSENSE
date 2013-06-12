class TutorialsController < ApplicationController
  # GET /tutorials
  # GET /tutorials.json
  skip_before_filter :authorize, only: [:show, :index]
  
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def index
    
    #Main List
    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end
    
    if sort=="ASC" or sort=="DESC"
      @tutorials = Tutorial.search(params[:search]).paginate(page: params[:page], per_page: 100).order("created_at #{sort}")
    else
      @tutorials = Tutorial.search(params[:search]).paginate(page: params[:page], per_page: 100).order("like_count DESC")
    end
    
    jsonObjects = []
    
    @tutorials.each do |t|
      if(!t.hidden)
        newJsonObject = {}
        
        newJsonObject["title"]          = t.title
        newJsonObject["timeAgoInWords"] = time_ago_in_words(t.created_at)
        newJsonObject["createdAt"]      = t.created_at.strftime("%B %d, %Y")
        newJsonObject["ownerName"]      = "#{t.owner.name}"
        newJsonObject["tutorialPath"] = tutorial_path(t)
        newJsonObject["ownerPath"]      = user_path(t.owner)
        
        jsonObjects = jsonObjects << newJsonObject
      end
    end
    
    respond_to do |format|
      format.html
      format.json { render json: jsonObjects }
    end
    
  end

  # GET /tutorials/1
  # GET /tutorials/1.json
  def show
    @tutorial = Tutorial.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tutorial }
    end
  end

  # GET /tutorials/new
  # GET /tutorials/new.json
  def new
    @tutorial = Tutorial.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tutorial }
    end
  end

  # GET /tutorials/1/edit
  def edit
    @tutorial = Tutorial.find(params[:id])
  end

  # POST /tutorials
  # POST /tutorials.json
  def create
    @tutorial = Tutorial.new({user_id: @cur_user.id, title: "#{@cur_user.name}'s Tutorial"})

    respond_to do |format|
      if @tutorial.save
        format.html { redirect_to @tutorial, notice: 'Tutorial was successfully created.' }
        format.json { render json: @tutorial, status: :created, location: @tutorial }
      else
        format.html { render action: "new" }
        format.json { render json: @tutorial.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tutorials/1
  # PUT /tutorials/1.json
  def update
    @tutorial = Tutorial.find(params[:id])
    editUpdate  = params[:tutorial]
    hideUpdate  = editUpdate.extract_keys!([:hidden])
    adminUpdate = editUpdate.extract_keys!([:featured_number])
    success = false
    
    #EDIT REQUEST
    if can_edit?(@tutorial) 
      success = @tutorial.update_attributes(editUpdate)
    end
    
    #HIDE REQUEST
    if can_hide?(@tutorial) 
      success = @tutorial.update_attributes(hideUpdate)
    end
    
    #ADMIN REQUEST
    if can_admin?(@tutorial)
      success = @tutorial.update_attributes(adminUpdate)
    end

    respond_to do |format|
      if success
        format.html { redirect_to @tutorial, notice: 'Tutorial was successfully updated.' }
        format.json { render status: :success }
      else
        format.html { render action: "edit" }
        format.json { render json: @tutorial.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tutorials/1
  # DELETE /tutorials/1.json
  def destroy
    @tutorial = Tutorial.find(params[:id])
    
    if can_delete?(@tutorial)
      
      @tutorial.user_id = -1
      @tutorial.hidden = true
      @tutorial.save
      
      respond_to do |format|
        format.html { redirect_to tutorials_url }
        format.json { render status: :success }
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render status: :forbidden }
      end
    end
  end
  
  # /tutorials/switch/
  # Switches between which tutorials are featured
  def switch

    #Which tutorial should we make featured
    to_tutorial = params[:selected]
    
    #Which featured tutorial are we changing
    featured_value = params[:location]
    
    old_tutorial = Tutorial.where("featured_number = ?",featured_value).first || nil
    
    #Set the old tutorials featured number to nil if necessary
    if !(old_tutorial == nil)
      old_tutorial.featured_number = nil
      old_tutorial.save
    end
    
    #Update the featured number for the selected tutorial
    new_tutorial = Tutorial.find_by_id(to_tutorial.to_i)
    new_tutorial.featured_number = featured_value.to_i    
    new_tutorial.save
    
    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
