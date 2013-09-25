class FieldsController < ApplicationController
  include ApplicationHelper
  # GET /fields/1
  # GET /fields/1.json
  def show
    @field = Field.find(params[:id])
    @owner = Project.find(@field.project_id).user_id
    
    recur = params.key?(:recur) ? params[:recur] : false
    
    respond_to do |format|
      format.html { render text: @field.to_json }
      format.json { render json: @field.to_hash(recur) }
    end
  end

  # POST /fields
  # POST /fields.json
  def create
    @field = Field.new(params[:field])    
    @project = Project.find(params[:field][:project_id])

    highest = 0
    
    @project.fields.all.each do |f|
      fname = f.name.split("_")
      if @field.name == fname[0] or @field.name == f
        if fname[1].nil?
          highest += 1
        else
          tmp = fname[1].to_i
          if tmp > highest
            highest = tmp
          end
        end
      end
    end
    
    if highest > 0
      @field.name += "_#{highest+1}"
      logger.info @field.name
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
    editUpdate  = params[:field]
    success = false
    
    #EDIT REQUEST
    if can_edit?(@field)
      
      unique = true
      
      # Enforce name uniqueness per project
      if params[:field].try(:[], :name)
        @field.owner.fields.all.each do |f|
          if f.id != params[:id].to_i
            if f.name == params[:field][:name]
              logger.info "Field name '#{f.name}' not unique"
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
        format.html { redirect_to @field.project, notice: 'Field was successfully updated.' }
        format.json { render json:{}, status: :ok }
      else
        logger.info "Errors: #{@field.errors.inspect}"
        format.html { redirect_to @field.project, alert: 'Field was not updated.' }
        format.json { render json: @field.errors.full_messages(), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1
  # DELETE /fields/1.json
  def destroy
    @field = Field.find(params[:id])
    
    if can_delete?(@field)
      @field.destroy
      
      if params.has_key?("project_id")
        num_fields = Project.find(params[:project_id]).fields.count
        respond_to do |format|
          format.html { redirect_to fields_url }
          format.json { render json: {num_fields: num_fields}, status: :ok }
        end
      else
        respond_to do |format|
          format.html { redirect_to fields_url }
          format.json { render json: {}, status: :ok }
        end
      end 
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end
 
  # POST /projects/id/updateFields 
  def updateFields
    errors = Field.bulk_update(params[:changes])
    
    if errors.length == 0
      respond_to do |format|
       format.json { render json: {}, status: :ok }
      end
    else
      logger.info errors.inspect
      respond_to do |format|
       format.json { render json: errors, status: :unprocessable_entity }
      end
    end
  end
end
