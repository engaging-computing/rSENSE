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
    
    if !params[:per_page].nil?
        pagesize = params[:per_page]
    else
        pagesize = 10;
    end
    
    if sort=="ASC" or sort=="DESC"
      @tutorials = Tutorial.search(params[:search]).paginate(page: params[:page], per_page: pagesize).order("created_at #{sort}")
    else
      @tutorials = Tutorial.search(params[:search]).paginate(page: params[:page], per_page: pagesize).order("like_count DESC")
    end
    
    recur = params.key?(:recur) ? params[:recur].to_bool : false
    
    respond_to do |format|
      format.html
      format.json { render json: @tutorials.map {|t| t.to_hash(recur)} }
    end
    
  end

  # GET /tutorials/1
  # GET /tutorials/1.json
  def show
    @tutorial = Tutorial.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tutorial.to_hash(false) }
    end
  end

  # POST /tutorials
  # POST /tutorials.json
  def create
    
    if is_admin?
      @tutorial = Tutorial.new({user_id: @cur_user.id, title: "#{@cur_user.name}'s Tutorial"})
      respond_to do |format|
        if @tutorial.save
          format.html { redirect_to @tutorial, notice: 'Tutorial was successfully created.' }
          format.json { render json: @tutorial.to_hash(false), status: :created, location: @tutorial }
        else
          format.html { render :status => 404 }
          format.json { render json: @tutorial.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render :status => 404 }
        format.json { render json: @tutorial.errors, status: :forbidden }
      end
    end
  end

  def edit
    @tutorial = Tutorial.find(params[:id])
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
        format.json { render json: {}, status: :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @tutorial.errors.full_messages(), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tutorials/1
  # DELETE /tutorials/1.json
  def destroy
    @tutorial = Tutorial.find(params[:id])
    
    if can_delete?(@tutorial)
      
      @tutorial.media_objects.each do |m|
        m.destroy
      end
      
      @tutorial.user_id = -1
      @tutorial.hidden = true
      @tutorial.save
      
      respond_to do |format|
        format.html { redirect_to tutorials_url }
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end
  
  # /tutorials/switch/
  # Switches between which tutorials are featured
  def switch
    new_tutorial = Tutorial.find(params[:tutorial])
    old_tutorial = Tutorial.where("featured_number = ?",params[:selected]).first || nil

    if can_admin?(new_tutorial) && (old_tutorial.nil? || can_admin?(old_tutorial))
      if !(old_tutorial == nil)
        old_tutorial.featured_number = nil
        old_tutorial.save
      end
      
      new_tutorial.featured_number = params[:selected].to_i    
      
      if new_tutorial.save
        respond_to do |format|
          format.json { render json: {}, status: :ok }
        end
      else
        logger.info "Apparently that tutorial isn't good enough"
        logger.info new_tutorial.errors
        respond_to do |format|
          format.json {render json: new_tutorial.errors, status: :unprocessable_entity}
        end
      end
    else
      respond_to do |format|
        logger.info "Sorry, your face can't switch tutorials"
        format.json { render json: {}, status: :forbidden }
      end
    end
  end
end
