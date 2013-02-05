class TutorialsController < ApplicationController
  # GET /tutorials
  # GET /tutorials.json
  skip_before_filter :authorize, only: [:show, :index]
  
  def index
    @tutorials = Tutorial.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tutorials }
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
    @tutorial = Tutorial.new(params[:tutorial])

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

    respond_to do |format|
      if @tutorial.update_attributes(params[:tutorial])
        format.html { redirect_to @tutorial, notice: 'Tutorial was successfully updated.' }
        format.json { head :no_content }
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
    @tutorial.destroy

    respond_to do |format|
      format.html { redirect_to tutorials_url }
      format.json { head :no_content }
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
