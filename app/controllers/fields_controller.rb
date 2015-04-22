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
    begin
      Field.verify_params(params[:field])
    rescue Exception => e
      respond_to do |format|
        format.json { render json: { msg: e }, status: :unprocessable_entity }
      end
      return
    end

    @field = Field.new(field_params)
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

  private

  def field_params
    params[:field].permit(:project_id, :field_type, :name, :unit, :restrictions)
  end
end
