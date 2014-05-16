class DataSetsController < ApplicationController
  include ApplicationHelper

  # Allow for export without authentication
  skip_before_filter :authorize, only: [:export, :manualEntry, :manualUpload, :update, :show, :dataFileUpload, :field_matching, :jsonDataUpload, :create]
  before_filter :authorize_allow_key, only: [:manualEntry, :manualUpload, :update, :show, :dataFileUpload, :field_matching, :jsonDataUpload, :create]

  # GET /data_sets/1
  # GET /data_sets/1.json
  def show
    @data_set = DataSet.find(params[:id])
    @mongo_data_set = { data: @data_set.data }
    recur = params.include?(:recur) ? params[:recur] == 'true' : false
    respond_to do |format|
      format.html { redirect_to project_path(@data_set.project) + data_set_path(@data_set) }
      format.json { render json: @data_set.to_hash(recur) }
    end
  end

  # GET /data_sets/1/edit
  def edit
    @data_set = DataSet.find(params[:id])
    @project = Project.find(@data_set.project_id)

    if @project.lock? and !can_edit?(@project)
      flash[:error] = "Can't edit data set, project is locked."
      redirect_to @project
      return
    end

    @fields = @project.fields

    unless params['data'].nil?
      uploader = FileUploader.new
      sane = uploader.sanitize_data(params['data'])
      if sane[:status]
        data_obj = sane[:data_obj]
        data = uploader.swap_columns(data_obj, @project)
        @data_set.data = data
        if @data_set.save!
          ret = { status: :success, redirect: "/projects/#{@project.id}/data_sets/#{@data_set.id}" }
        else
          ret = { status: :unprocessable_entity, msg: @data_set.errors.full_messages }
        end
      else
        err_msg = sane[:status] ? dataset.errors.full_messages : sane[:msg]
        respond_to do |format|
          format.json { render json: { data: sane[:data_obj], msg: err_msg }, status: :unprocessable_entity }
        end
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
    @data_set = DataSet.new(data_set_params)
    @project  = @data_set.project

    if @project.lock? and !can_edit?(@project) and !key?(@project)
      redirect_to @project, alert: 'Project is locked'
      return
    end

    if @cur_user.nil?
      @data_set.user_id = @project.user_id
    else
      @data_set.user_id = @cur_user.id
    end

    respond_to do |format|
      if @data_set.save
        format.html { redirect_to @data_set, notice: 'Project data set was successfully created.' }
        format.json { render json: @data_set.to_hash(false), status: :created, location: @data_set }
      else
        format.html do
          flash[:error] = @data_set.errors
          redirect_to @data_set
        end
        format.json { render json: @data_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /data_sets/1
  # PUT /data_sets/1.json
  def update
    @data_set = DataSet.find(params[:id])
    @project  = @data_set.project

    if @project.lock? and !can_edit?(@project)
      redirect_to @project, alert: 'Project is locked'
      return
    end

    respond_to do |format|
      if can_edit?(@data_set) && @data_set.update_attributes(data_set_params)
        format.html { redirect_to @data_set, notice: 'DataSet was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        @data_set.errors[:base] << 'Permission denied' unless can_edit?(@data_set)
        format.html { render action: 'edit' }
        format.json { render json: @data_set.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_sets/1
  # DELETE /data_sets/1.json
  def destroy
    @data_set = DataSet.find(params[:id])
    @project  = @data_set.project

    if @project.lock? and !can_edit?(@project)
      redirect_to @project, alert: 'Project is locked'
      return
    end

    if can_delete?(@data_set)

      @data_set.media_objects.each do |m|
        m.destroy
      end

      respond_to do |format|
        if @data_set.destroy
          format.html { redirect_to root_path, notice: 'Data set removed' }
          format.json { render json: {}, status: :ok }
        else
          format.html { redirect_to project_path(@data_set.project.id), notice: 'Data set could not be removed' }
          format.json { render json: {}, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/403.html', status: :forbidden }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end

  # GET /projects/1/manualEntry
  def manualEntry
    @project = Project.find(params[:id])

    if @project.lock? and !can_edit?(@project) and !key?(@project)
      redirect_to @project, alert: 'Project is locked'
      return
    end
  end

  # POST /projects/1/jsonDataUpload
  # {data => { "20"=>[1,2,3,4,5], "21"=>[6,7,8,9,10], "22"=>['v','w','x','y','z'] }}
  def jsonDataUpload
    project = Project.find(params['id'])

    if project.lock? and !can_edit?(project) and !key?(project)
      render text: 'Project is locked', status: 401
      return
    end

    uploader = FileUploader.new
    sane = uploader.sanitize_data(params[:data])

    if sane[:status]
      data_obj = sane[:data_obj]
      data = uploader.swap_columns(data_obj, project)
      dataset = DataSet.new do |d|
        d.user_id = @cur_user.try(:id) || project.owner.id
        d.title = params[:title]
        d.project_id = project.id
        d.data = data
        unless can_edit? @project
          logger.info key_name project.id, params[:contribution_key]
          if session[:key]
            d.key = session[:key]
          else 
            d.key = key_name(project.id, params[:contribution_key])
          end
                                
          #project not locked and @cur_user.try(:id)
          #have session[key]
          #dont have session[key]
          
          
          
        #unless owner
        #unless can_edit? @project
          #logger.info 'Cannot edit project!'
          #logger.info 'Session[:key] is:'
          #logger.info session[:key]
          #logger.info 'Params[:contribution_key]'
          #logger.info params[:contribution_key]
          #if not locked and logged in
          #if (!project.lock?) and d.user_id == @cur_user.try(:id)
            #logger.info '#if not locked and logged in'
            #d.key = nil
          #if not locked and not logged in
          #els if !project.lock? and d.user_id != @cur_user.try(:id)
            #logger.info '#if not locked and not logged in'
            #if !session[:key].nil?
              #logger.info 'session[:key] not nil'
              #logger.info session[:key]
              #d.key = session[:key]
            #els if !key_name( project.id, params[:contribution_key] ).nil?
              #logger.info 'params[:contribution_key] is not nil'
              #logger.info 'params[:contribution_key]'
              #d.key = key_name( project.id, params[:contribution_key] )
            #else 
              #logger.info 'project isnt locked, but no key'
              #d.key = nil
            #end inner else if
            #end 
          #els if project.lock?
            #logger.info 'Project locked!'
            #unless session[:key].nil?
              #logger.info 'Setting d.key := session[:key]'
              #d.key = session[:key]
            #els if !key_name( project.id, params[:contribution_key]).nil?
              #logger.info 'Setting d.key := key_name project.id, params[:contribution_key]'
              #d.key = key_name( project.id, params[:contribution_key] )
            #else
              #'Nothing happened'
              #d.key = nil
            #end
          #end
        #end unless can_edit?
        end
      
      #endif
      end

      respond_to do |format|
        if dataset.save
          format.json { render json: dataset.to_hash(false), status: :ok }
        else
          format.json { render json: { msg: dataset.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    else
      err_msg = sane[:status] ? dataset.errors.full_messages : sane[:msg]
      respond_to do |format|
        format.json { render json: { data: sane[:data_obj], msg: err_msg }, status: :unprocessable_entity }
      end
    end
  end

  # GET /projects/1/export
  def export_concatenated
    require 'uri'
    require 'tempfile'

    csv = Project.find(params[:id]).export_concatenated(params[:datasets])

    respond_to do |format|
      format.html { send_file csv, type: 'file/text', x_sendfile: true }
    end
  end

  # GET /projects/1/export
  def export
    require 'uri'
    require 'tempfile'

    zip_file = Project.find(params[:id]).export_data_sets(params[:datasets])

    respond_to do |format|
      format.html { send_file zip_file, type: 'file/zip', x_sendfile: true }
    end
  end

  # PUT /data_sets/field_matching
  def field_matching
    project = Project.find(params[:pid])
    uploader = FileUploader.new
    data_obj = uploader.retrieve_obj(params[:file])
    sane = uploader.sanitize_data(data_obj, params[:matches])
    if sane[:status]
      data_obj = sane[:data_obj]
      data = uploader.swap_columns(data_obj, project)
      dataset = DataSet.new do |d|
        d.user_id = @cur_user.try(:id) || project.owner.id
        d.title = params[:title]
        d.project_id = project.id
        d.data = data
        unless can_edit? @project
          d.key = key_name(project.id, session[:key])
        end
      end

      if @cur_user.nil?
        if params[:contrib_name].empty?
          dataset.errors[:base] << 'Must enter contributor name'
        else
          dataset.title += " - #{params[:contrib_name]}"
        end
      end

      if dataset.errors[:base].empty? and dataset.save
        redirect_to "/projects/#{project.id}/data_sets/#{dataset.id}"
      else
        @results = params[:results]
        @default_name = params[:title]
        respond_to do |format|
          flash[:error] = dataset.errors.full_messages
          format.html { render action: 'dataFileUpload' }
        end
      end
    else
      respond_to do |format|
        flash[:error] = "Data could not be saved: #{sane[:msg]}"
        format.html { redirect_to project }
      end
    end
  end

  # POST /data_sets/uploadCSV2
  def dataFileUpload
    project = Project.find(params[:pid])

    if project.lock? and !can_edit?(project) and !key?(project)
      redirect_to @project, alert: 'Project is locked'
      return
    end

    begin
      uploader = FileUploader.new
      data_obj = uploader.generateObject(params[:file])
      @results = uploader.match_headers(project, data_obj)

      @default_name = DataSet.get_next_name(project)

      respond_to do |format|
        format.html
      end
    rescue Exception => e
      logger.info "File could not be read: #{e}"
      flash[:error] = 'File could not be read'
      redirect_to project_path(project)
    end
  end

  private

  def data_set_params
    params[:data_set].permit(:project_id, :title, :user_id, :hidden, :key, :data)
  end
end
