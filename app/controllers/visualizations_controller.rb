class VisualizationsController < ApplicationController
  include ApplicationHelper
  skip_before_filter :authorize, only: [:show, :displayVis, :index]
  
  # GET /visualizations
  # GET /visualizations.json
  def index
    @visualizations = Visualization.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @visualizations }
    end
  end

  # GET /visualizations/1
  # GET /visualizations/1.json
  def show
    @visualization = Visualization.find(params[:id])
    @project = Project.find_by_id(@visualization.project_id)

    # The finalized data object
    @Data = { savedData: @visualization.data, savedGlobals: @visualization.globals }

    respond_to do |format|
      format.html
    end
  end

  # GET /visualizations/new
  # GET /visualizations/new.json
  def new
    @visualization = Visualization.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @visualization }
    end
  end

  # GET /visualizations/1/edit
  def edit
    @visualization = Visualization.find(params[:id])
  end

  # POST /visualizations
  # POST /visualizations.json
  def create
    params[:visualization][:user_id] = @cur_user.id
    @visualization = Visualization.new(params[:visualization])

    respond_to do |format|
      if @visualization.save
        format.html { redirect_to @visualization, notice: 'Visualization was successfully created.' }
        format.json { render json: @visualization.id, status: :created, location: @visualization }
      else
        format.html { render action: "new" }
        format.json { render json: @visualization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /visualizations/1
  # PUT /visualizations/1.json
  def update
    @visualization = Visualization.find(params[:id])

    respond_to do |format|
      if @visualization.update_attributes(params[:visualization])
        format.html { redirect_to @visualization, notice: 'Visualization was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @visualization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visualizations/1
  # DELETE /visualizations/1.json
  def destroy
    @visualization = Visualization.find(params[:id])
    @visualization.destroy

    respond_to do |format|
      format.html { redirect_to visualizations_url }
      format.json { head :no_content }
    end
  end

  # GET 
  def displayVis
    
    @project = Project.find_by_id params[:id]
    
    @datasets = []
    data_fields = []
    format_data = []
    metadata = {}
    rel_viz = []
    total = 0
    field_count = []
    
    # build list of datasets
    if( !params[:datasets].nil? )
      
      dsets = params[:datasets].split(",")
      dsets.each do |s|
        begin
          @datasets.push DataSet.find_by_id_and_project_id s, params[:id]
        rescue
          logger.info "Either project id or dataset does not exist in the DB"
        end
      end
    else
      @datasets = DataSet.find_all_by_project_id params[:id]
    end
    
    # get data for each dataset    
    @datasets.each do |dataset|
      d = MongoData.find_by_data_set_id(dataset.id)
      logger.info "------------------------"
      logger.info dataset
      dataset[:data] = d.data
    end

    # create special dataset grouping field
    data_fields.push({ typeID: TEXT_TYPE, unitName: "String", fieldID: -1, fieldName: "Dataset Name (id)" })
    # create special grouping field for all datasets
    data_fields.push({ typeID: TEXT_TYPE, unitName: "String", fieldID: -1, fieldName: "Combined Datasets" })
    
    # push real fields to temp variable
    @project.fields.each do |field|
      data_fields.push({ typeID: field.field_type, unitName: field.unit, fieldID: field.id, fieldName: field.name })
    end
    
    
    # create/push metadata for datasets
    @datasets.each do |dataset|
      dataset.data.each do |rows|
        metadata["#{dataset.title}(#{dataset.id})"] = { name: dataset.title, user_id: dataset.user_id, dataset_id: dataset.id, timecreated: dataset.created_at, timemodified: dataset.updated_at }
        arr = []
        arr.push "#{dataset.title}(#{dataset.id})"
        arr.push "All"
        rows.each do |dp|
          key = dp.keys
          arr.push dp[key[0]]
        end
        format_data.push arr
      end
    end
    
    field_count = [0,0,0,0,0,0]
    
    @project.fields.each do |field|
      field_count[field.field_type] += 1 
    end

    rel_vis = []

    # Determine which visualizations are relevant
    if field_count[LONGITUDE_TYPE] > 0 and field_count[LATITUDE_TYPE] > 0
      rel_vis.push "Map"
    end

    if field_count[TIME_TYPE] > 0 and field_count[NUMBER_TYPE] > 0 and format_data.count > 1
      rel_vis.push "Timeline"
    end
    
    if field_count[NUMBER_TYPE] > 1 and format_data.count > 1
      rel_vis.push "Scatter"
    end
    
    if field_count[NUMBER_TYPE] > 0 and format_data.count > 1
      rel_vis.push "Histogram"
      rel_vis.push "Bar"
    end
    
    rel_vis.push "Table"
    
    if field_count[TIME_TYPE] > 0 and field_count[NUMBER_TYPE] > 0 and format_data.count > 1
      rel_vis.push "Motion"
    end

    # A list of all current visualizations
    allVis =  ['Map','Timeline','Scatter','Bar','Histogram','Table','Motion','Photos']

    # The finalized data object
    @Data = { projectName: @project.title, projectID: @project.id, hasPics: false, fields: data_fields, dataPoints: format_data, metadata: metadata, relVis: rel_vis, allVis: allVis }
    
    
    respond_to do |format|
      format.html
    end
  end
  
end
