class TutorialsController < ApplicationController
  # GET /tutorials
  # GET /tutorials.json
  skip_before_filter :authorize, only: [:show, :index]
  
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def index
    
    @params = params
    
    #Main List
    if !params[:sort].nil?
      sort = params[:sort]
    else
      sort = "updated_at"
    end
    
    if !params[:order].nil?
      order = params[:order]
    else
      order = "DESC"
    end
    
    if !params[:per_page].nil?
        pagesize = params[:per_page]
    else
        pagesize = 50;
    end
    
    @tutorials = Tutorial.search(params[:search]).paginate(page: params[:page], per_page: pagesize)
    
    @tutorials = @tutorials.order("#{sort} #{order}")
    
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
    adminUpdate = editUpdate.extract_keys!([:featured])
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
      if adminUpdate.has_key?(:featured)
        if adminUpdate['featured'] == true
          adminUpdate['featured_at'] = Time.now()
        else
          adminUpdate['featured_at'] = nil
        end
      end
    
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
end
