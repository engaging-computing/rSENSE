class DataSetsController < ApplicationController
  include ApplicationHelper

  # Allow for export without authentication
  skip_before_filter :authorize, :only => [:export, :manualEntry, :manualUpload, :update, :show, :dataFileUpload, :field_matching]
  before_filter :authorize_allow_key, :only => [:manualEntry, :manualUpload, :update, :show, :dataFileUpload, :field_matching]

  # GET /data_sets/1
  # GET /data_sets/1.json
  def show
    @data_set = DataSet.find(params[:id])
    @mongo_data_set = { data: @data_set.data }
    recur = params.key?(:recur) ? params[:recur] == "true" : false
    respond_to do |format|
      format.html { redirect_to (project_path @data_set.project) + (data_set_path @data_set) }
      format.json { render json: @data_set.to_hash(recur)}
    end
  end

  # GET /data_sets/new
  # GET /data_sets/new.json
  def new
    @data_set = DataSet.new

    respond_to do |format|
      format.html
      format.json { render json: @data_set.to_hash(false) }
    end
  end

  # GET /data_sets/1/edit
  def edit
    @data_set = DataSet.find(params[:id])
    @project = Project.find(@data_set.project_id)
    @fields = @project.fields

    header_to_field_map = []

    if !params["data"].nil? and !params["headers"].nil?
      @project.fields.each do |field|
        params["headers"].each_with_index do |header, header_index|
          if header.to_i == field.id
            header_to_field_map.push header_index
          end
        end
      end

      new_data = []

      params["data"]["0"].each_with_index do |tmp, row_index|

        row = {}

        header_to_field_map.each do |htf, htf_index|
          if params["data"]["#{htf}"][row_index] == ""
            val = nil
          else
            val = params["data"]["#{htf}"][row_index]
          end
          row["#{@fields[htf].id}"] = val
        end

        new_data[row_index] = row

      end

      @data_set.data = new_data

      if @data_set.save!
        ret = { status: :success, redirect: "/projects/#{@project.id}/data_sets/#{@data_set.id}" }
      else
        ret = :error
      end
    end

    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: ret }
    end

  end
  
  # POST /data_sets
  # POST /data_sets.json
  def create
    @data_set = DataSet.new(params[:data_set])

    respond_to do |format|
      if @data_set.save
        format.html { redirect_to @data_set, notice: 'Project data set was successfully created.' }
        format.json { render json: @data_set.to_hash(false), status: :created, location: @data_set }
      else
        format.html { render action: "new" }
        format.json { render json: @data_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /data_sets/1
  # PUT /data_sets/1.json
  def update
    @data_set = DataSet.find(params[:id])
    editUpdate  = params[:data_set]
    hideUpdate  = editUpdate.extract_keys!([:hidden])
    success = false

    #EDIT REQUEST
    if can_edit?(@data_set)
      success = @data_set.update_attributes(editUpdate)
    end

    #HIDE REQUEST
    if can_hide?(@data_set)
      success = @data_set.update_attributes(hideUpdate)
    end

    respond_to do |format|
      if @data_set.update_attributes(params[:data_set])
        format.html { redirect_to @data_set, notice: 'DataSet was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @data_set.errors.full_messages(), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_sets/1
  # DELETE /data_sets/1.json
  def destroy
    @data_set = DataSet.find(params[:id])

    if can_delete?(@data_set)

      @data_set.media_objects.each do |m|
        m.destroy
      end
      
      respond_to do |format|
        if @data_set.destroy     
          format.html { redirect_to root_path, notice: "Data set removed" }
          format.json { render json: {}, status: :ok }
        else
          format.html { redirect_to project_path(@data_set.project.id), notice: "Data set could not be removed" }
          format.json { render json: {}, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end

  # GET /projects/1/manualEntry
  def manualEntry
    @project = Project.find(params[:id])
  end

  # POST /projects/1/manualUpload
  def manualUpload

    ############ Sanity Checks ############
    errors = []
    sane = true
    
    if params[:data].nil?
      errors.push "'data' cannot be nil."
      sane = false
    end
    
    if params[:headers].nil?
      errors.push "'headers' cannot be nil."
      sane = false
    end
    
    if params[:id].nil?
      errors.push "'id' cannot be nil."
      sane = false
    end
    
    if sane && !(params[:data].length == params[:headers].length)
      errors.push "Number of data columns (#{params[:data].length}) does not match number of headers (#{params[:headers].length})."
      sane  = false
    end
    
    if !sane
      #insane in the membrane
      respond_to do |format|
        format.json { render json: errors, status: :unprocessable_entity }
      end
      return
    end
    #######################################
    
    @project = Project.find(params[:id])
    @fields = @project.fields
    header_to_field_map = {}
    success = false
    defaultName = ""
    
    if !params[:name]
      defaultName  = "Dataset ##{(DataSet.where(project_id: params[:id]).to_a.count + 1).to_s}"
    else
      defaultName = params["name"]
    end

    # Generate field mappings
    @project.fields.each do |field|
      params[:headers].each_with_index do |header, header_index|
        if header.to_i == field.id
          header_to_field_map["#{field.id}"] =  header_index
        end
      end
    end
    
    if header_to_field_map.count != @fields.count
      #headers dont match... womp womp wahhhhh
      errors.push "Number of headers (#{header_to_field_map.count}) does not match the number of fields (#{@fields.count})"
      logger.info "Data set headers don't match fields"
      logger.info errors.inspect
      respond_to do |format|
        format.json { render json: errors, status: :unprocessable_entity }
      end
      return
    end
    
    # Format data
    new_data = []

    params[:data]["0"].each_with_index do |tmp, row_index|

      row = {}

      header_to_field_map.each do |key, value|
        if params["data"]["#{value}"][row_index] == ""
          val = nil
        else
          val = params["data"]["#{value}"][row_index]
        end
        row["#{key}"] = val
      end


      new_data[row_index] = row

    end

    owner = @cur_user.try(:id) ? @cur_user.id : @project.owner.id

    @data_set = DataSet.new(:user_id => owner, :project_id => @project.id, 
                               :title => defaultName, data: new_data)

    followURL = "/projects/#{@project.id}/data_sets/#{@data_set.id}"

    respond_to do |format|
      if @data_set.save
        format.json { render json: @data_set.to_hash(false), status: :created}
      else
        format.json { render json:{}, status: :unprocessable_entity }
      end
    end

  end

  # GET /projects/1/export
  def export
    require 'uri'
    require 'tempfile'
    
    zip_file = Project.find(params[:id]).export_data_sets(params[:datasets])
    
    respond_to do |format|
      format.html { send_file zip_file, :type => 'file/zip', :x_sendfile => true }
    end

  end

  # PUT /data_sets/field_matching
  def field_matching
    project = Project.find(params[:pid])
    uploader = FileUploader.new
    data_obj = uploader.retrieve_obj(params[:file])
    sane = uploader.sanitize_data(data_obj, project, params[:matches])
    if sane[:status]
      data_obj = sane[:data_obj]
      data = uploader.swap_columns(data_obj, project, params[:matches])
      dataset = DataSet.new do |d|
        d.user_id = @cur_user.try(:id) || project.owner.id
        d.title = params[:title]
        d.project_id = project.id
        d.data = data
      end
      if dataset.save
        redirect_to "/projects/#{project.id}/data_sets/#{dataset.id}"
      else
        @results = params[:results]
        @default_name = params[:title]
        respond_to do |format|
          flash[:error] = dataset.errors.full_messages()
          format.html {render action: "uploadCSV2"}
        end
      end
    else
      respond_to do |format|
        flash[:error] = "Data could not be saved: #{sane[:msg]}"
        format.html {redirect_to project}
      end
    end
  end
  
  # POST /data_sets/uploadCSV2
  def dataFileUpload
    project = Project.find(params[:pid])
    
    begin
      uploader = FileUploader.new
      data_obj = uploader.generateObject(params[:file])
      @results = uploader.match_headers(project, data_obj)
      
      @default_name = "Dataset ##{ (DataSet.where(project_id: params[:pid]).to_a.count + 1).to_s}"
    
      respond_to do |format|
        format.html
      end
    rescue Exception => e
      flash[:error] = 'File could not be read'
      redirect_to project_path(project)
    end
  end
end
