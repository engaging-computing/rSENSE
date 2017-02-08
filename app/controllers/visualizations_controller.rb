class VisualizationsController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  skip_before_filter :authorize, only: [:show, :displayVis, :index, :embedVis]

  after_action :allow_iframe, only: [:show, :displayVis]

  before_action :set_vis_list

  def set_vis_list
    # A list of all current visualizations
    @all_vis =  ['Map', 'Timeline', 'Scatter', 'Bar', 'Histogram', 'Pie', 'Table', 'Summary', 'Photos']
  end

  # GET /visualizations
  # GET /visualizations.json
  def index
    # Main List
    @params = params

    if !params[:sort].nil?
      sort = params[:sort]
    else
      sort = 'created_at'
    end

    if !params[:order].nil?
      order = params[:order]
    else
      order = 'DESC'
    end

    if !params[:per_page].nil?
      pagesize = params[:per_page]
    else
      pagesize = 48
    end

    @visualizations = Visualization.search(params[:search]).paginate(page: params[:page], per_page: pagesize)

    @visualizations = @visualizations.order("#{sort} #{order}")

    respond_to do |format|
      format.html
      format.json { render json: @visualizations.map { |v| v.to_hash(false) } }
    end
  end

  def param_vis_check(params)
    param_vis = nil
    unless params[:vis].nil?
      vis_name = params[:vis].capitalize
      param_vis = @all_vis.include?(vis_name) ? vis_name : nil
    end
    param_vis
  end

  # GET /visualizations/1
  # GET /visualizations/1.json
  def show
    @visualization = Visualization.find(params[:id])
    @project = Project.find_by_id(@visualization.project_id)
    tmp = JSON.parse(@visualization.data)
    param_vis = param_vis_check(params)

    # The finalized data object
    @data = {
      savedData:    @visualization.data,
      savedGlobals: @visualization.globals,
      defaultVis:   param_vis || tmp['defaultVis'],
      relVis:       tmp['relVis']
    }

    recur = params.key?(:recur) ? params[:recur] == 'true' : false

    options = {}

    # Detect presentation mode (and force embed)
    if params.try(:[], :presentation) and params[:presentation]
      @presentation = true
      options[:presentation] = 1
      params[:embed] = true
    else
      @presentation = false
    end

    respond_to do |format|
      format.html do
        if params.try(:[], :embed) and params[:embed]
          options[:isEmbed] = 1
          options[:startCollapsed] = 1
          @globals = { options: options }
          render 'embed', layout: 'embedded'
        else
          @layout_wide = true
          render
        end
      end
      format.json { render json: @visualization.to_hash(recur) }
    end
  end

  def edit
    @visualization = Visualization.find(params[:id])
  end

  # POST /visualizations
  # POST /visualizations.json
  def create
    params[:visualization][:user_id] = current_user.id

    # Remove any piggybacking updates
    if params[:visualization].try(:[], :tn_file_key)
      params[:visualization].delete :tn_file_key
    end
    if params[:visualization].try(:[], :tn_src)
      params[:visualization].delete :tn_src
    end

    # Try to make a thumbnail
    mo = nil

    if params[:visualization].try(:[], :svg)
      begin
        mo = MediaObject.new
        mo.media_type = 'image'
        mo.name = 'image.png'
        mo.file = 'image.png'
        mo.user_id = current_user.id
        mo.check_store!

        image = MiniMagick::Image.read(params[:visualization][:svg], '.svg')
        image.format 'png'
        image.resize '512x512'

        File.open(mo.file_name, 'wb') do |ff|
          ff.write(image.to_blob)
        end

        mo.add_tn
      rescue MiniMagick::Invalid => err
        mo = nil
        logger.info "Failed to create thumbnail (#{err})."
      end

      params[:visualization].delete :svg
    end

    @visualization = Visualization.new(visualization_params)

    respond_to do |format|
      if @visualization.save
        unless mo.nil?
          mo.visualization_id = @visualization.id
          mo.save!
          @visualization.thumb_id = mo.id
          @visualization.save!
        end

        flash[:notice] = 'Visualization was successfully created.'
        format.html { redirect_to @visualization }
        format.json { render json: @visualization.to_hash(false), status: :created }
      else
        format.html { render action: 'new' }
        format.json { render json: @visualization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /visualizations/1
  # PUT /visualizations/1.json
  def update
    @visualization = Visualization.find(params[:id])
    update = visualization_params

    # ADMIN REQUEST
    if can_admin?(@visualization)
      if update.key?(:featured)
        if update['featured'] == '1'
          update['featured_at'] = Time.now
        else
          update['featured_at'] = nil
        end
      end
    end

    respond_to do |format|
      if can_edit?(@visualization) && @visualization.update_attributes(update)
        format.html { redirect_to @visualization, notice: 'Visualization was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        @visualization.errors[:base] << 'Permission denied' unless can_edit?(@visualization)
        format.html { redirect_to request.referrer, alert: @visualization.errors.full_messages }
        format.json do
          render json: @visualization.errors.full_messages,
          status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /visualizations/1
  # DELETE /visualizations/1.json
  def destroy
    begin
      @visualization = Visualization.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json: { error: 'Visualization not found.' }, status: :not_found }
      end
      return
    end

    if can_delete?(@visualization)

      @visualization.media_objects.each(&:destroy)

      @visualization.destroy

      respond_to do |format|
        format.html { redirect_to visualizations_url }
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to '/401.html' }
        format.json { render json: { errors: ['User Not Authorized.'] }, status: :forbidden }
      end
    end
  end

  # GET
  def displayVis
    @project = Project.find_by_id params[:id]
    if @project.nil?
      respond_to do |format|
        format.html { redirect_to '/404.html' }
        format.json { render json: { errors: ['File not found.'] }, status: 404 }
      end
      return
    end

    @datasets = []
    data_fields = []
    format_data = []
    metadata = {}
    field_count = []

    # build list of datasets
    if !params[:datasets].nil?
      dsets = params[:datasets].split(',')
      dsets.each do |id|
        begin
          dset = DataSet.find_by_id(id)
          if dset.project_id == @project.id
            @datasets.push dset
          else
            fail 'data set does not belong to project'
          end
        rescue
          respond_to do |format|
            format.html { redirect_to '/404.html' }
            format.json { render json: { errors: ['File not found.'] }, status: 404 }
          end
          return
        end
      end
    else
      @datasets = DataSet.where(project_id: params[:id])
    end

    # create special row identifier field for all datasets
    data_fields.push(typeID: NUMBER_TYPE, unitName: 'id', fieldID: -1, fieldName: 'Data Point')
    # create special dataset grouping field
    data_fields.push(typeID: TEXT_TYPE, unitName: 'String', fieldID: -1, fieldName: 'Data Set Name (id)')
    # create special grouping field for all datasets
    data_fields.push(typeID: TEXT_TYPE, unitName: 'String', fieldID: -1, fieldName: 'Combined Data Sets')
    # create special grouping field for number fields
    data_fields.push(typeID: TEXT_TYPE, unitName: 'String', fieldID: -1, fieldName: 'Number Fields')
    # create a special grouping field for contributors
    data_fields.push(typeID: TEXT_TYPE, unitName: 'String', fieldID: -1, fieldName: 'Contributors')
    # create a special grouping field for time period (when enabled on timeline)
    data_fields.push(typeID: TEXT_TYPE, unitName: 'String', fieldID: -1, fieldName: 'Time Period')
    lat = ''
    time_field = ''
    num_field = ''
    # push real fields to temp variable
    @project.fields.sort_by(&:index).each do |field|
      data_fields.push(typeID: field.field_type, unitName: field.unit, fieldID: "#{field.id}", fieldName: field.name)
      # check if location and timestamp fields exist
      lat = field.id.to_s if field.field_type == 4
      time_field = field.id.to_s if field.field_type == 1
      num_field = field.id.to_s if field.field_type == 2
    end

    # push formula fields to temp variable
    @project.formula_fields.sort_by(&:index).each do |field|
      data_fields.push(typeID: field.field_type, unitName: field.unit, fieldID: "f#{field.id}", fieldName: field.name, formula: true)
    end

    has_pics = false
    has_loc_data = false

    # create/push metadata for datasets
    i = 0
    time_count = 0
    num_count = 0
    @datasets.each do |dataset|
      photos = dataset.media_objects.to_a.keep_if { |mo| mo.media_type == 'image' }.map { |mo| mo.to_hash(true) }
      has_pics = true if photos.size > 0
      metadata[i] = { name: dataset.title, user_id: dataset.user_id, dataset_id: dataset.id, timecreated: dataset.created_at, timemodified: dataset.updated_at, photos: photos }
      dataset.data.each_with_index do |row, index|
        # check if location and/or timestamp data exists
        has_loc_data = true if has_loc_data == false and lat != '' and row.key?(lat) and row[lat] != ''
        time_count += 1 if time_count < 3 and time_field != '' and row.key?(time_field) and row[time_field] != ''
        num_count += 1 if num_count < 3 and num_field != '' and row.key?(num_field) and row[num_field] != ''
        unless row.class == Hash
          logger.info 'Bad row in JSON data:'
          logger.info row.inspect
        end

        arr = []
        arr.push index + 1
        arr.push "#{dataset.title}(#{dataset.id})"
        arr.push 'All'
        arr.push ''
        arr.push dataset.key.nil? ? "User: #{User.select(:name).find(dataset.user_id).name}" : "Key: #{dataset.key}"
        arr.push ''

        data_fields.slice(arr.length, data_fields.length).each do |field|
          if field[:formula]
            arr.push dataset.formula_data[index][field[:fieldID][1..-1]]
          else
            arr.push row[field[:fieldID]]
          end
        end

        format_data.push arr
      end

      i += 1
    end

    # Timeline needs at least 3 datapoints
    has_time_data = true if time_count > 2 and num_count > 2

    # Count the number of each type of field
    field_count = [0, 0, 0, 0, 0, 0]
    @project.fields.each do |field|
      field_count[field.field_type] += 1
    end
    @project.formula_fields.each do |field|
      field_count[field.field_type] += 1
    end

    rel_vis = which_vis(has_time_data, has_loc_data, has_pics, field_count, format_data)

    # Defaut vis if one exists for the project
    default_vis = @project.default_vis.nil? ? 'none' : @project.default_vis

    param_vis = param_vis_check(params)

    # The finalized data object
    @data = { projectName: @project.title,   projectID: @project.id,
              fields: data_fields,           dataPoints: format_data,
              metadata: metadata,            relVis: rel_vis,
              allVis: @all_vis,              defaultVis: param_vis || default_vis,
              precision: @project.precision, savedGlobals: @project.globals,
              hasTimeData: time_count != 0 }

    options = {}

    # Detect presentation mode (and force embed)
    if params.try(:[], :presentation) and params[:presentation]
      @presentation = true
      options[:presentation] = 1
      params[:embed] = true
    else
      @presentation = false
    end

    @data_set = @datasets.first

    respond_to do |format|
      format.html do
        if params.try(:[], :embed) and params[:embed]
          options[:isEmbed] = 1
          options[:startCollapsed] = 1
          @globals = { options: options }
          render 'embedProjVis', layout: 'embedded'
        else
          @layout_wide = true
          render
        end
      end
    end
  end

  private

  def visualization_params
    if current_user.try(:admin)
      params[:visualization].permit(:content, :data, :project_id, :globals, :title, :user_id, :featured,
                                    :featured_at, :tn_src, :tn_file_key, :summary, :thumb_id, :featured_media_id)
    else
      params[:visualization].permit(:content, :data, :project_id, :globals, :title, :user_id,
                                    :tn_src, :tn_file_key, :summary, :thumb_id, :featured_media_id)
    end
  end

  def which_vis(has_time_data, has_loc_data, has_pics, field_count, format_data)
    visualizations = []

    # Determine which visualizations are relevant
    if field_count[LONGITUDE_TYPE] > 0 and field_count[LATITUDE_TYPE] > 0 and has_loc_data
      visualizations.push 'Map'
    end

    if field_count[TIME_TYPE] > 0 and field_count[NUMBER_TYPE] > 0 and format_data.count > 2 and has_time_data
      visualizations.push 'Timeline'
    end

    if field_count[NUMBER_TYPE] > 0 and format_data.count > 1
      visualizations.push 'Scatter'
    end

    if format_data.count > 0
      visualizations.push 'Bar'
      visualizations.push 'Pie'
      visualizations.push 'Histogram'
    end

    visualizations.push 'Table'
    visualizations.push 'Summary'

    if has_pics
      visualizations.push 'Photos'
    end

    visualizations
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
