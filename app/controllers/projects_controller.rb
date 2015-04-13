class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.json
  skip_before_filter :authorize, only: [:show, :index]

  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def index
    @params = params

    # Main List
    if !params[:sort].nil? and ['like_count', 'views', 'created_at',
                                'updated_at'].include? params[:sort]
      sort = params[:sort]
    else
      sort = 'updated_at'
    end

    if !params[:order].nil?
      order = params[:order]
    else
      order = 'DESC'
    end

    if !params[:per_page].nil?
      pagesize = params[:per_page]
    else
      pagesize = 50
    end

    templates = params.key? 'templates_only'
    curated = params.key? 'curated_only'
    featured = params.key? 'featured_only'
    has_data = params.key? 'has_data'

    @projects = Project.search(params[:search])

    @projects = @projects.order("#{sort} #{order}")

    @projects = @projects.only_templates(templates).only_curated(curated)
      .only_featured(featured).has_data(has_data)

    count = @projects.length

    @projects = @projects.paginate(page: params[:page], per_page: pagesize,
                                   total_entries: count)

    @project = Project.new

    respond_to do |format|
      format.html
      format.json { render json: @projects.map { |p| p.to_hash(false) } }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @params = params
    @project = Project.find(params[:id])

    # Determine if the project is cloned
    @cloned_project = nil
    unless @project.cloned_from.nil?
      @cloned_project = Project.find(@project.cloned_from)
    end

    @liked_by_cur_user = false
    if Like.find_by_user_id_and_project_id(@cur_user, @project.id)
      @liked_by_cur_user = true
    end

    # checks for fields
    @has_fields = false
    if @project.fields.count > 0
      @has_fields = true
    end

    @data_sets = @project.data_sets.search(params[:search])
    if @data_sets.nil?
      @data_sets = []
    end

    recur = params.key?(:recur) ? params[:recur] == 'true' : false

    respond_to do |format|
      format.html do
        # Update view count
        session[:viewed] ||= {}
        session[:viewed][:projects] ||= {}

        unless session[:viewed][:projects][@project.id]
          session[:viewed][:projects][@project.id] = true
          @project.add_view!
        end

        # render show.html.erb
      end
      format.json { render json: @project.to_hash(recur) }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])

    @new_contrib_key = ContribKey.new
    @new_contrib_key.project_id = @project.id
  end

  # POST /projects
  # POST /projects.json
  def create
    if params[:project_id]
      cloned_from = Project.find(params[:project_id])
      @project = cloned_from.clone(params, @cur_user.id)
    else
      @cloned_project = nil
      @project = Project.new project_params
      @project.user_id = @cur_user.id
    end

    respond_to do |format|
      if @project.save
        format.html do
          redirect_to @project, notice: 'Project was successfully created.'
        end
        format.json do
          render json: @project.to_hash(false),
          status: :created, location: @project
        end
      else
        flash[:error] = @project.errors.full_messages
        format.html { redirect_to projects_path }
        format.json do
          render json: @project.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])
    update = project_params

    # ADMIN REQUEST
    if @cur_user.try(:admin)
      if update.key?(:featured)
        if update['featured'] == 'true'
          update['featured_at'] = Time.now
        else
          update['featured_at'] = nil
        end
      end

      if update.key?(:curated)
        if update['curated'] == 'true'
          update['curated_at'] = Time.now
          update['lock'] = true
        else
          update['curated_at'] = nil
        end
      end
    end

    respond_to do |format|
      if can_edit?(@project) && @project.update_attributes(update)
        format.html do
          redirect_to @project, notice: 'Project was successfully updated.'
        end
        format.json { render json: {}, status: :ok }
      else
        @project.errors[:base] << 'Permission denied' unless can_edit?(@project)
        format.html { render action: 'edit' }
        format.json do
          render json: @project.errors.full_messages,
          status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])

    unless can_delete?(@project)
      respond_to do |format|
        format.html { redirect_to '/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
      return
    end

    if @project.data_sets.length > 0
      respond_to do |format|
        format.html do
          redirect_to [:edit, @project],
          alert: "Can't delete project with data sets"
        end
        format.json { render json: {}, status: :forbidden }
      end
      return
    end

    @project.media_objects.each do |m|
      m.destroy
    end

    @project.destroy

    respond_to do |format|
      format.html do
        redirect_to projects_url, notice: "Project deleted: #{@project.title}"
      end
      format.json { render json: {}, status: :ok }
    end
  end

  # POST /projects/1/updateLikedStatus
  def updateLikedStatus
    like = Like.find_by_user_id_and_project_id(@cur_user, params[:id])

    if like
      if Like.destroy(like.id)
        count = Project.find(params[:id]).likes.count
        respond_to do |format|
          format.json { render json: { update: count }, status: :ok }
        end
      else
        respond_to do |format|
          format.json { render json: {}, status: :forbidden }
        end
      end

    else
      if Like.create(user_id: @cur_user.id, project_id: params[:id])
        count = Project.find(params[:id]).likes.count
        respond_to do |format|
          format.json { render json: { update: count }, status: :ok }
        end
      else
        respond_to do |format|
          format.json { render json: {}, status: :forbidden }
        end
      end
    end
  end

  def edit_fields
    @project = Project.find(params[:id])
  end

  def save_fields
    @project = Project.find(params[:id])

    # Save all the fields
    @project.fields.each do |field|
      restrictions = nil
      if params.key?("#{field.id}_restrictions")
        restrictions = params["#{field.id}_restrictions"].split(',')
        if restrictions.count < 1
          restrictions = nil
        end
      end

      unless field.update_attributes(name: params["#{field.id}_name"],
                                     unit: params["#{field.id}_unit"],
                                     restrictions: restrictions)
        respond_to do |format|
          flash[:error] = 'Field names must be unique'
          redirect_to "/projects/#{@project.id}/edit_fields"
          return
        end
      end
    end

    # If there's a new field, add it the number of times specified.
    field_type = params[:new_field]

    if field_type == 'Location'
      latitude  = Field.new(project_id: @project.id,
                            field_type: get_field_type('Latitude'),
                            name: 'Latitude',
                            unit: 'deg')
      longitude = Field.new(project_id: @project.id,
                            field_type: get_field_type('Longitude'),
                            name: 'Longitude',
                            unit: 'deg')

      unless latitude.save && longitude.save
        flash[:error] = "#{latitude.errors.full_messages}\n"\
          "\n#{longitude.errors.full_messages}"
        redirect_to "/projects/#{@project.id}/edit_fields"
        return
      end
    elsif !field_type.nil?
      ((params[:num_fields].to_i > params[:text_fields].to_i) ? params[:num_fields].to_i : params[:text_fields].to_i).times do

        next_name = Field.get_next_name(@project,
                                        get_field_type(params[:new_field]))
        field = Field.new(project_id: @project.id,
                          field_type: get_field_type(field_type), name: next_name)

        unless field.save
          flash[:error] = field.errors.full_messages
          redirect_to "/projects/#{@project.id}/edit_fields"
          return
        end
      end
    end
    if field_type.nil?
      redirect_to project_path(@project), notice: 'Changes to fields saved.'
    else
      redirect_to "/projects/#{@project.id}/edit_fields", notice: "#{field_type} field added."
    end
  end

  def templateUpload
    @project = Project.find(params[:id])
    @options = [['Timestamp', get_field_type('Timestamp')],
                ['Number', get_field_type('Number')],
                ['Text', get_field_type('Text')],
                ['Latitude', get_field_type('Latitude')],
                ['Longitude', get_field_type('Longitude')]]

    uploader = FileUploader.new
    data_obj = uploader.generateObjectForTemplateUpload(params[:file])

    @types = data_obj[:types]
    @original_filename = params[:file].original_filename.split('.')[0]
    @tmp_file = data_obj[:file]
    @headers = data_obj[:headers]
    @has_data = data_obj[:has_data]

    respond_to do |format|
      format.html
    end
  rescue Exception => e
    flash[:error] = "Error reading file: #{e}"
    redirect_to project_path(@project)
  end

  def finishTemplateUpload
    uploader = FileUploader.new
    @matches = params[:headers]
    @project = Project.find(params[:id])
    @matches.each do |header|
      field = Field.new(project_id: @project.id,
                        field_type: header[1].to_i, name: header[0])

      unless field.save
        respond_to do |format|
          flash[:error] = field.errors.full_messages
          render 'templateUpload' and return
        end
      end
    end

    if params.key?('create_dataset')
      data_obj = uploader.retrieve_obj(params[:file])
      data = uploader.swap_with_field_names(data_obj, @project)

      dataset = DataSet.new do |d|
        d.user_id = @cur_user.id
        d.title = params[:title]
        d.project_id = @project.id
        d.data = data
      end

      if dataset.save
        redirect_to "/projects/#{@project.id}/data_sets/#{dataset.id}"
      else
        @headers = data_obj['data'].keys
        flash[:error] = dataset.errors.full_messages
      end
    else
      redirect_to @project
    end
  end

  def clone
    @project = Project.find(params[:id])
    @clone = Project.new
    @clone.title = @project.title + ' (clone)'
    @clone.content = @project.content
    @cloned_project = @project
    respond_to do |format|
      format.html
    end
  end

  private

  def project_params
    if @cur_user.try(:admin)
      return params[:project].permit(:content, :title, :user_id, :filter,
                                     :cloned_from, :has_fields, :featured,
                                     :is_template, :featured_media_id, :hidden,
                                     :featured_at, :lock, :curated,
                                     :curated_at, :updated_at, :default_vis,
                                     :precision, :globals, :kml_metadata)
    end

    params[:project].permit(:content, :title, :user_id, :filter, :hidden,
                            :cloned_from, :has_fields, :featured_media_id,
                            :lock, :updated_at, :default_vis, :precision,
                            :globals, :kml_metadata)
  end
end
