class DataSetsController < ApplicationController
  include ApplicationHelper
  include DataSetsHelper

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

    if can_edit? @data_set
      @cols, @data = format_slickgrid @fields, @data_set.data
    end

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
          ret = { status: :unprocessable_entity, error: @data_set.errors.full_messages, msg: @data_set.errors.full_messages }
        end
      else
        err_msg = sane[:status] ? dataset.errors.full_messages : sane[:msg]
        respond_to do |format|
          format.json { render json: { data: sane[:data_obj], error: err_msg, msg: err_msg }, status: :unprocessable_entity }
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

    if !current_user.nil?
      @data_set.user_id = current_user.id
    elsif !session[:contributor_name].nil?
      @data_set.user_id = @project.user_id
      @data_set.contributor_name = session[:contributor_name]
    else
      @data_set.user_id = @project.user_id
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
        format.html { redirect_to @data_set, notice: 'Data set was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        @data_set.errors[:base] << 'Permission denied' unless can_edit?(@data_set)
        format.html { redirect_to request.referrer, alert: @data_set.errors.full_messages }
        format.json { render json: @data_set.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_sets/1
  # DELETE /data_sets/1.json
  def destroy
    begin
      @data_set = DataSet.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json: { errors: ['Data set not found.'] }, status: :not_found }
      end
      return
    end
    @project  = @data_set.project
    @errors = []

    if @project.lock? and !can_edit?(@project)
      redirect_to @project, alert: 'Project is locked'
      return
    end

    if can_delete?(@data_set)

      @data_set.media_objects.each(&:destroy)

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
      @errors.push 'User Not Authorized.'

      respond_to do |format|
        format.html { redirect_to 'public/403.html', status: :forbidden }
        format.json { render json: { errors: @errors }, status: :forbidden }
      end
    end
  end

  # DELETE /delete_data_sets/1,2,3...
  def deleteMultiple
    dataset_ids = params[:id_list].split(',')
    @dataset_array = []
    dataset_ids.each do |id|
      begin
        dset = DataSet.find(id)
        @dataset_array.push dset
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.json { render json: { error: 'Data set not found' }, status: :not_found }
        end
        return
      end
      unless can_delete?(dset)
        respond_to do |format|
          format.html { redirect_to 'public/403.html', status: :forbidden }
          format.json { render json: { error: 'User not authorized' }, status: :forbidden }
        end
        return
      end
      @project ||= @dataset_array[0].project
    end
    amount = @dataset_array.length

    if @project.lock? and !can_edit?(@project)
      redirect_to @project, alert: 'Project is locked'
      return
    end

    @dataset_array.each do |data_set|
      data_set.media_objects.each(&:destroy)

      unless data_set.destroy
        respond_to do |format|
          format.html { redirect_to project_path(@data_set.project.id), notice: 'Data set could not be removed' }
          format.json { render json: { error: 'Unprocessable Entity' }, status: :unprocessable_entity }
        end
        return
      end
    end

    flash[:notice] = "Successfully deleted #{amount} data set" + (amount == 1 ? '' : 's') + '.'
    respond_to do |format|
      format.html { redirect_to request.referrer, notice: 'Data sets removed' }
      format.json { render json: {}, status: :ok }
    end
  end

  # GET /projects/1/manualEntry
  def manualEntry
    @project = Project.find(params[:id])
    @fields = @project.fields

    if @project.lock? and !can_edit?(@project) and !key?(@project)
      redirect_to @project, alert: 'Project is locked'
      return
    end

    @cols, @data = format_slickgrid @fields, []
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
        d.user_id = current_user.try(:id) || project.owner.id
        d.title = params[:title]
        d.project_id = project.id
        d.data = data
        params[:contributor_name] ||= session[:contributor_name]
        unless params[:contributor_name].nil?
          if params[:contributor_name].length == 0
            d.contributor_name = 'Contributed via Key'
          else
            d.contributor_name = params[:contributor_name]
          end
        end
        unless can_edit? @project
          if session[:key]
            d.key = session[:key]
          else
            d.key = key_name(project.id, params[:contribution_key])
          end
        end
      end

      respond_to do |format|
        if dataset.save
          format.json { render json: dataset.to_hash(false), status: :ok }
        else
          format.json { render json: { error: dataset.errors.full_messages, msg: dataset.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    else
      err_msg = sane[:status] ? dataset.errors.full_messages : sane[:msg]
      respond_to do |format|
        format.json { render json: { data: sane[:data_obj], error: err_msg, msg: err_msg }, status: :unprocessable_entity }
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
    files = params[:files]
    titles = params[:titles]

    files.each_with_index do |file, index|
      pid = params[:pid]
      project = Project.find(pid)
      uploader = FileUploader.new
      data_obj = uploader.retrieve_obj(file)
      matches = params[:matches]
      sane = uploader.sanitize_data(data_obj, matches["#{index}"])

      if sane[:status]
        data_obj = sane[:data_obj]
        data = uploader.swap_columns(data_obj, project)

        dataset = DataSet.new do |d|
          d.user_id = current_user.try(:id) || project.owner.id
          d.title = titles[index]
          d.project_id = project.id
          d.data = data
          unless params[:contributor_name].nil?
            if params[:contributor_name].length == 0
              d.contributor_name = 'Contributed via Key'
            else
              d.contributor_name = params[:contributor_name]
            end
          end
          unless can_edit? @project
            d.key = key_name(project.id, session[:key])
          end
        end

        if dataset.errors[:base].empty? and dataset.save
          if files.size == 1
            redirect_to "/projects/#{project.id}/data_sets/#{dataset.id}"
            return
          elsif index + 1 == files.size
            redirect_to "/projects/#{project.id}"
            return
          end
        else
          @results = params[:results]
          @filenames = params[:titles]
          respond_to do |format|
            flash[:error] = dataset.errors.full_messages
            format.html { render action: 'dataFileUpload' }
          end
          return
        end

      else
        respond_to do |format|
          flash[:error] = "Data could not be saved: #{sane[:msg]}"
          format.html { redirect_to project }
        end
        return
      end
    end
  end

  # POST /data_sets/dataFileUpload
  def dataFileUpload
    require 'tempfile'
    require 'rubygems'
    require 'zip'

    project = Project.find(params[:pid])

    if project.lock? and !can_edit?(project) and !key?(project)
      redirect_to project, alert: 'Project is locked'
      return
    end

    if params[:gdoc]
      value = params[:gdoc]
      if value.include?('key=')
        value = value.split('key=')[1].split('&')[0]
        gcsv = "https://docs.google.com/spreadsheet/pub?key=#{value}&single=true&gid=0&output=csv"
      elsif value.include?('spreadsheets/d/')
        value = value.split('spreadsheets/d/')[1].split('/')[0]
        gcsv = "https://docs.google.com/spreadsheets/d/#{value}/export?gid=0&format=csv"
      end
    end

    if params[:file] && params[:file].size > 10000000
      redirect_to project, alert: 'Maximum upload size of a single data set is 10 MB. Please split your file into multiple pieces and upload them individually.'
      return
    end

    if params[:file] && params[:file].original_filename.split('.')[-1] == 'zip'
      Zip::File.open(params[:file].path) do |zip_file|
        results = []
        filenames = []
        zip_file.each do |entry|
          if entry.directory?
            next
          elsif entry.file?
            if entry.name.include? '__MACOSX' or entry.name.include? 'DS_Store'
              next
            end
            begin
              tempfile = Tempfile.new(entry.name.split('/')[-1])
              tempfile.write(entry.get_input_stream.read)

              uploader = FileUploader.new
              data_obj = uploader.generateObject(tempfile)
              results.push(uploader.match_headers(project, data_obj))

              filenames.push(DataSet.get_next_name(project, entry.name.split('/')[-1].split('.')[0]))

            rescue Exception
              flash[:error] = "Error reading file #{entry.name}"
              next
            end
            next
          else
            flash[:error] = "Error reading #{entry.name.split('/')[-1]}"
            next
          end
        end
        if results.any?
          @filenames = filenames
          @results = results
          respond_to do |format|
            format.html
            return
          end
        end
      end
      redirect_to project_path(project)
      return
    elsif params[:file]
      @filenames = [DataSet.get_next_name(project, params[:file].original_filename.split('.')[0])]
    elsif !params[:file]
      @filenames = [DataSet.get_next_name(project, 'Google docs')]
    end

    begin
      uploader = FileUploader.new
      data_obj = uploader.generateObject(params[:file] ? params[:file] : gcsv)
      @results = [uploader.match_headers(project, data_obj)]

      respond_to do |format|
        format.html
      end
    rescue Exception => e
      flash[:error] = "Error reading file: #{e}"
      redirect_to project_path(project)
    end
  end

  private

  def data_set_params
    params[:data_set].permit(:project_id, :title, :user_id, :key, :data)
  end
end
