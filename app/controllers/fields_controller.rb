class FieldsController < ApplicationController
  include ApplicationHelper
  # GET /fields/1
  # GET /fields/1.json
  skip_before_filter :authorize, only: [:show]

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
    @field = Field.new(field_params)
    unless @field.valid?
      respond_to do |format|
        errs = @field.errors.full_messages.join ', '
        format.json { render json: { msg: errs }, status: :unprocessable_entity }
      end
      return
    end

    @project = Project.find(params[:field][:project_id])

    unless params[:field].key?(:name)
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

    respond_to do |format|
      if can_edit?(@field) && @field.update_attributes(field_params)
        format.html { redirect_to @field.project, notice: 'Field was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        @field.errors[:base] << ('Permission denied') unless can_edit?(@field)
        logger.error "Errors: #{@field.errors.inspect}"
        format.html { redirect_to Field.find(params[:id]), alert: 'Field was not updated.' }
        format.json { render json: @field.errors.full_messages, status: :unprocessable_entity }
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
        @project.fields.where('field_type = ?', get_field_type('Latitude')).first.destroy
        @project.fields.where('field_type = ?', get_field_type('Longitude')).first.destroy
      else
        @field.destroy
      end
      respond_to do |format|
        format.json { render json: {}, status: :ok }
        format.html { redirect_to @field.project, notice: 'Field was successfuly deleted.' }
      end
    else
      @errors = []
      if @project.data_sets.count > 0
        @errors.push 'Project Not Empty.'
      end
      if (can_delete?(@field) == false)
        @errors.push 'User Not Authorized.'
      end
      respond_to do |format|
        format.json { render json: { errors: @errors }, status: :forbidden }
        format.html { redirect_to @field.project, alert: 'Field could not be destroyed' }
      end
    end
  end

  private

  def field_params
    params[:field].permit(:project_id, :field_type, :name, :unit, :restrictions, :index)
  end
end
