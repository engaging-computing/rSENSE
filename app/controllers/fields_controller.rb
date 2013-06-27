class FieldsController < ApplicationController
  
  include ApplicationHelper

  # GET /fields/1
  # GET /fields/1.json
  def show
    @field = Field.find(params[:id])
    @owner = Project.find(@field.project_id).user_id
    
    recur = params.key?(:recur) ? params[:recur] : false
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @field.to_hash(recur) }
    end
  end

  # POST /fields
  # POST /fields.json
  def create
    @field = Field.new(params[:field])    
    @project = Project.find(params[:field][:project_id])

    counter = 1
    
    @project.fields.all.each do |f|
      fname = f.name.split("_")
      if @field.name == fname[0] or @field.name == f
        counter += 1
      end
    end
    
    if counter > 1
      @field.name += "_#{counter}"
    end
    
    respond_to do |format|
      if @field.save
        format.html { redirect_to @field, notice: 'Field was successfully created.' }
        format.json { render json: @field.to_hash(false), status: :created, location: @field }
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
    editUpdate  = params[:field].to_hash
    success = false
    
    #EDIT REQUEST
    if can_edit?(@field)
      
      unique = true
      
      #Enforce name uniqueness per project
      if params[:field].try(:[], :name)
        @field.owner.fields.all.each do |f|
          if f.id != params[:id].to_i
            if f.name == params[:field][:name]
              unique = false
            end
          end
        end
      end
      
      if unique
        success = @field.update_attributes(editUpdate)
      end
    end
    
    respond_to do |format|
      if success
        format.html { redirect_to @field, notice: 'Field was successfully updated.' }
        format.json { render json:{}, status: :ok }
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
    
    if can_delete?(@field)
      @field.destroy
      
      respond_to do |format|
        format.html { redirect_to fields_url }
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
