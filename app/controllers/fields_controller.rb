class FieldsController < ApplicationController
  # GET /fields
  # GET /fields.json
  def index
    @fields = Field.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fields }
    end
  end

  # GET /fields/1
  # GET /fields/1.json
  def show
    @field = Field.find(params[:id])
    @owner = Experiment.find(@field.experiment_id).user_id
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @field }
    end
  end

  # GET /fields/new
  # GET /fields/new.json
  def new
    @field = Field.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @field }
    end
  end

  # GET /fields/1/edit
  def edit
    @field = Field.find(params[:id])
  end

  # POST /fields
  # POST /fields.json
  def create
    @field = Field.new(params[:field])    
    @experiment = Experiment.find(params[:field][:experiment_id])

    counter = 1
    
    @experiment.fields.all.each do |f|
      fname = f.name.split("_")
      if @field.name == fname[0] or @field.name == f
        counter += 1
      end
    end
    
    if counter > 0
      @field.name += "_#{counter}"
    end
    
    respond_to do |format|
      if @field.save
        format.html { redirect_to @field, notice: 'Field was successfully created.' }
        format.json { render json: @field, status: :created, location: @field }
      else
        format.html { render action: "new" }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fields/1
  # PUT /fields/1.json
  def update
    @field = Field.find(params[:id])

    respond_to do |format|
      if @field.update_attributes(params[:field])
        format.html { redirect_to @field, notice: 'Field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1
  # DELETE /fields/1.json
  def destroy
    @field = Field.find(params[:id])
    @field.destroy

    respond_to do |format|
      format.html { redirect_to fields_url }
      format.json { head :no_content }
    end
  end
end
