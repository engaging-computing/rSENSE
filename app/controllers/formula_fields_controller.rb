class FormulaFieldsController < ApplicationController
  include ApplicationHelper
  skip_before_filter :authorize, only: [:show]

  # GET /formula_fields/1
  # GET /formula_fields/1.json
  def show
    @field = FormulaField.find(params[:id])
    @owner = Project.find(@field.project_id).user_id

    recur = params.key?(:recur) ? params[:recur] : false

    respond_to do |format|
      format.html { render text: @field.to_json }
      format.json { render json: @field.to_hash(recur) }
    end
  end

  # POST /formula_fields
  # POST /formula_fields.json
  def create
    @field = FormulaField.new(field_params)
    unless @field.valid?
      respond_to do |format|
        errs = @field.errors.full_messages.join ', '
        format.json { render json: { msg: errs }, status: :unprocessable_entity }
      end
      return
    end

    @project = Project.find(params[:field][:project_id])

    unless params[:field].key?(:name)
      @field.name = FormulaField.get_next_name(@project, @field.field_type)
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
    @field = FormulaField.find(params[:id])

    respond_to do |format|
      if can_edit?(@field) && @field.update_attributes(field_params)
        format.html { redirect_to @field.project, notice: 'Field was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        @field.errors[:base] << ('Permission denied') unless can_edit?(@field)
        logger.error "Errors: #{@field.errors.inspect}"
        format.html { redirect_to FormulaField.find(params[:id]), alert: 'Field was not updated.' }
        format.json { render json: @field.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1
  # DELETE /fields/1.json
  def destroy
    @field = FormulaField.find(params[:id])
    @project = Project.find(@field.project_id)
    if can_delete?(@field) && (@project.data_sets.count == 0)
      @field.destroy
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
    params[:field].permit(:project_id, :field_type, :name, :unit, :index, :formula)
  end
end
