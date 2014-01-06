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
    
    if !params[:field].has_key? :name
      @field.name = Field.get_next_name(@project, @field.field_type)
    end
    
    respond_to do |format|
      if @field.save
        format.json { render json: @field.to_hash(false), status: :created, location: @field }
      else
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
      success = @field.update_attributes(editUpdate)
    end
    
    respond_to do |format|
      if success
        format.html { redirect_to @field.project, notice: 'Field was successfully updated.' }
        format.json { render json:{}, status: :ok }
      else
        logger.error "Errors: #{@field.errors.inspect}"
        format.html { redirect_to Field.find(params[:id]), alert: 'Field was not updated.' }
        format.json { render json: @field.errors.full_messages(), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1
  # DELETE /fields/1.json
  def destroy
    @field = Field.find(params[:id])
    @project = Project.find(@field.project_id)
    if can_delete?(@field) && (@project.data_sets.count == 0)
      if (@field.field_type == get_field_type('Latitude')) || (@field.field_type == get_field_type('Longitude'))
        @project.fields.where("field_type = ?", get_field_type('Latitude')).first.destroy
        @project.fields.where("field_type = ?", get_field_type('Longitude')).first.destroy
      else
        @field.destroy
      end
      respond_to do |format|
        format.json { render json:{}, status: :ok }
        format.html { redirect_to @field.project, notice: 'Field was successfuly deleted.' }
      end
    else
      respond_to do |format|
        format.json { render json:{}, status: :forbidden }
        format.html { redirect_to @field.project, alert: 'Field could not be destroyed' }
      end
    end

  end
end
