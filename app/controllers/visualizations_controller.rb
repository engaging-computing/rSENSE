class VisualizationsController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::DateHelper
  
  skip_before_filter :authorize, only: [:show, :displayVis, :index, :embedVis]
  
  # GET /visualizations
  # GET /visualizations.json
  def index
        #Main List
    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end
    
    if !params[:per_page].nil?
        pagesize = params[:per_page]
    else
        pagesize = 10;
    end
    
    if sort=="ASC" or sort=="DESC"
      @visualizations = Visualization.search(params[:search]).paginate(page: params[:page], per_page: pagesize).order("created_at #{sort}")
    else
      @visualizations = Visualization.search(params[:search]).paginate(page: params[:page], per_page: pagesize).order("like_count DESC")
    end
    
    #Featured list
    @featured_3 = Visualization.where(featured: true).order("updated_at DESC").limit(3);
    
    respond_to do |format|
      format.html
      format.json { render json: @visualizations.map {|v| v.to_hash(false) } }
    end
    
  end

  # GET /visualizations/1
  # GET /visualizations/1.json
  def show
    @visualization = Visualization.find(params[:id])
    @project = Project.find_by_id(@visualization.project_id)

    # The finalized data object
    @Data = { savedData: @visualization.data, savedGlobals: @visualization.globals }

    recur = params.key?(:recur) ? params[:recur].to_bool : false
    
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
          @Globals = { options: options }
          render 'embed', :layout => 'embedded'
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
    params[:visualization][:user_id] = @cur_user.id
    
    # Remove any piggybacking updates
    if params[:visualization].try(:[], :tn_file_key)
      params[:visualization].delete :tn_file_key
    end
    if params[:visualization].try(:[], :tn_src)
      params[:visualization].delete :tn_src
    end
    
    #Try to make a thumbnail
    if params[:visualization].try(:[], :svg)
      begin
        image = MiniMagick::Image.read(params[:visualization][:svg], '.svg')
        image.format 'png'
        image.resize '128'
        
        s3ConfigFile = YAML.load_file('config/aws_config.yml')
        s3 = AWS::S3.new(
          :access_key_id => s3ConfigFile['access_key_id'],
          :secret_access_key => s3ConfigFile['secret_access_key'])
      
        bucket = s3.buckets['isenseimgs']
        fileKey = SecureRandom.uuid() + ".svg"
        while Visualization.find_by_tn_file_key(fileKey) != nil
          fileKey = SecureRandom.uuid() + ".svg"
        end
        o = bucket.objects[fileKey]
        o.write image.to_blob
        
        params[:visualization][:tn_file_key] = fileKey
        params[:visualization][:tn_src] = o.public_url.to_s
        
      rescue MiniMagick::Invalid => err
        logger.info "Failed to create thumbnail."
      end
      params[:visualization].delete :svg
    end
    
    @visualization = Visualization.new(params[:visualization])

    respond_to do |format|
      if @visualization.save
        flash[:notice] = 'Visualization was successfully created.'
        format.html { redirect_to @visualization }
        format.json { render json: @visualization.to_hash(false), status: :created}
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
    editUpdate  = params[:visualization]
    hideUpdate  = editUpdate.extract_keys!([:hidden])
    adminUpdate = editUpdate.extract_keys!([:featured])
    success = false
   
    #EDIT REQUEST
    if can_edit?(@visualization) 
      success = @visualization.update_attributes(editUpdate)
    end
    
    #HIDE REQUEST
    if can_hide?(@visualization) 
      success = @visualization.update_attributes(hideUpdate)
    end
    
    #ADMIN REQUEST
    if can_admin?(@visualization) 
      
      if adminUpdate.has_key?(:featured)
        if adminUpdate['featured'] == "1"
          adminUpdate['featured_at'] = Time.now()
        else
          adminUpdate['featured_at'] = nil
        end
      end
      
      success = @visualization.update_attributes(adminUpdate)
    end
    
    respond_to do |format|
      if success
        format.html { redirect_to @visualization, notice: 'Visualization was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @visualization.errors.full_messages(), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visualizations/1
  # DELETE /visualizations/1.json
  def destroy
    @visualization = Visualization.find(params[:id])
    
    if can_delete?(@visualization)
      
      @visualization.media_objects.each do |m|
        m.destroy
      end
      
      @visualization.hidden = true
      @visualization.user_id = -1
      @visualization.save
      
      respond_to do |format|
        format.html { redirect_to visualizations_url }
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
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
      dsets.each do |id|
        begin
          dset = DataSet.find_by_id(id.to_i)
          if dset.project_id == @project.id
            @datasets.push dset
          end
        rescue
          logger.info "Either project id or dataset does not exist in the DB"
        end
      end
    else
      @datasets = DataSet.find_all_by_project_id(params[:id], :conditions => {hidden: false})
    end
    
    # create special dataset grouping field
    data_fields.push({ typeID: TEXT_TYPE, unitName: "String", fieldID: -1, fieldName: "Dataset Name (id)" })
    # create special grouping field for all datasets
    data_fields.push({ typeID: TEXT_TYPE, unitName: "String", fieldID: -1, fieldName: "Combined Datasets" })
    
    # push real fields to temp variable
    @project.fields.each do |field|
      data_fields.push({ typeID: field.field_type, unitName: field.unit, fieldID: field.id, fieldName: field.name })
    end
    
    hasPics = false
    # create/push metadata for datasets
    i = 0
    @datasets.each do |dataset|
      hasPics = true if dataset.media_objects.size > 0
      metadata[i] = { name: dataset.title, user_id: dataset.user_id, dataset_id: dataset.id, timecreated: dataset.created_at, timemodified: dataset.updated_at, photos: dataset.media_objects }
      dataset.data.each do |row|
        unless row.class == Hash
          logger.info "Bad row in JSON data:"
          logger.info row.inspect
        end

        arr = []
        arr.push "#{dataset.title}(#{dataset.id})"
        arr.push "All"

        data_fields.slice(2, data_fields.length).each do |field|
          arr.push row[field[:fieldID].to_s]
        end
        format_data.push arr
      end
      i+=1
    end
    
    #Count the number of each type of field
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
      rel_vis.push "Bar"
      rel_vis.push "Histogram"
    end
    
    rel_vis.push "Table"
    
#     if field_count[TIME_TYPE] > 0 and field_count[NUMBER_TYPE] > 0 and format_data.count > 1
#       rel_vis.push "Motion"
#     end
    
    if hasPics
      rel_vis.push "Photos"
    end
    
    # A list of all current visualizations
    allVis =  ['Map','Timeline','Scatter','Bar','Histogram','Table','Photos']

    # The finalized data object
    @Data = { projectName: @project.title, projectID: @project.id, fields: data_fields, dataPoints: format_data, metadata: metadata, relVis: rel_vis, allVis: allVis }

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
          @Globals = { options: options }
          render 'embed', :layout => 'embedded'
        else
          @layout_wide = true
          render
        end
      end
    end
  end
  
end
