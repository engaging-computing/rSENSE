class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.json
  skip_before_filter :authorize, only: [:show, :index]

  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def index
    @params = params

    # Main List
    if !params[:sort].nil? and ['like_count', 'views', 'created_at', 'updated_at'].include? params[:sort]
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

    @projects = @projects.only_templates(templates).only_curated(curated).only_featured(featured).has_data(has_data)

    count = @projects.length

    @projects = @projects.paginate(page: params[:page], per_page: pagesize, total_entries: count)

    respond_to do |format|
      format.html
      format.json { render json: @projects.map { |p| p.to_hash(false) } }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])

    # Update view count
    session[:viewed] ||= {}
    session[:viewed][:projects] ||= {}

    unless session[:viewed][:projects][@project.id]
      session[:viewed][:projects][@project.id] = true
      @project.add_view!
    end

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
    if  @project.fields.count > 0
      @has_fields = true
    end

    @data_sets = @project.data_sets.where(hidden: false)
    if @data_sets.nil?
      @data_sets = []
    end

    recur = params.key?(:recur) ? params[:recur] == 'true' : false

    respond_to do |format|
      format.html # show.html.erb
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
    # @project = Project.new(params[:project])
    if params[:project_id]
      # Clone
      @cloned = Project.find(params[:project_id])
      @project = @cloned.dup
      @project.user_id = @cur_user.id
      @project.cloned_from = @cloned.id
      @project.featured = false
      @project.curated = false
      @project.lock = false
      if params[:project_name].nil?
        @project.title = "#{@cloned.title} (clone)"
      else
        @project.title = params[:project_name]
      end

      success = @project.save
      if success

        # Clone fields
        field_map = {}
        @cloned.fields.each do |f|
          nf = f.dup
          nf.project_id = @project.id
          nf.save
          field_map[f.id.to_s] = nf.id.to_s
        end

        # Clone project media
        @cloned.media_objects.each do |mo|
          if mo.data_set_id.nil?
            nmo = mo.cloneMedia
            nmo.project_id = @project.id
            nmo.user_id = @cur_user.id
            nmo.save!

            unless @cloned.content.nil?
              @cloned.content.gsub! mo.src, nmo.src
            end

            if @project.featured_media_id == mo.id
              @project.featured_media_id = nmo.id
            end
          end
        end

        if params[:clone_datasets]
          # Clone datasets
          @cloned.data_sets.each do |ds|
            nds = ds.dup
            nds.project_id = @project.id
            nds.user_id = @cur_user.id

            # Fix data fields
            data = nds.data
            new_data = []
            data.each do |row|
              field_map.each do |old_key, new_key|
                row[new_key] = row[old_key]
                row.delete old_key
              end
              new_data.push row
            end
            nds.data = new_data
            nds.save!

            # Clone dataset media
            ds.media_objects.each do |mo|
              nmo = mo.cloneMedia
              nmo.data_set_id = nds.id
              nmo.project_id = @project.id
              nmo.user_id = @cur_user.id

              nmo.save!
              unless nds.content.nil?
                nds.content.gsub! mo.src, nmo.src
              end
            end

            nds.save!
          end
        end
      end

      success &= @project.save
    else
      if params[:project_name].nil?
        if @cur_user.name[-1].downcase == 's'
          title = "#{@cur_user.name}' Project"
        else
          title = "#{@cur_user.name}'s Project"
        end
        @project = Project.new(user_id: @cur_user.id, title: title)
      else
        @project = Project.new(user_id: @cur_user.id, title: params[:project_name])
      end
      success = @project.save
    end

    respond_to do |format|
      if success
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project.to_hash(false), status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1s
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
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        @project.errors[:base] << 'Permission denied' unless can_edit?(@project)
        format.html { render action: 'edit' }
        format.json { render json: @project.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])

    if can_delete?(@project)

      @project.data_sets.each do |d|
        d.hidden = true
        d.user_id = -1
        d.save
      end

      @project.media_objects.each do |m|
        m.destroy
      end

      @project.user_id = -1
      @project.hidden = true
      @project.save

      respond_to do |format|
        format.html { redirect_to projects_url }
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to '/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
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

      unless field.update_attributes(name: params["#{field.id}_name"], unit: params["#{field.id}_unit"],
                                     restrictions: restrictions)
        respond_to do |format|
          flash[:error] = 'Field names must be unique'
          redirect_to "/projects/#{@project.id}/edit_fields"
          return
        end
      end
    end

    # If there's a new field, add it.
    field_type = params[:new_field]

    if field_type == 'Location'
      latitude  = Field.new(project_id: @project.id, field_type: get_field_type('Latitude'), name: 'Latitude', unit: 'deg')
      longitude = Field.new(project_id: @project.id, field_type: get_field_type('Longitude'), name: 'Longitude', unit: 'deg')

      unless latitude.save && longitude.save
        flash[:error] = "#{latitude.errors.full_messages}\n\n#{longitude.errors.full_messages}"
        redirect_to "/projects/#{@project.id}/edit_fields"
        return
      end
    elsif field_type != ''
      next_name = Field.get_next_name(@project, get_field_type(params[:new_field]))
      field = Field.new(project_id: @project.id, field_type: get_field_type(field_type), name: next_name)

      unless field.save
        flash[:error] = field.errors.full_messages
        redirect_to "/projects/#{@project.id}/edit_fields"
        return
      end
    end

    if field_type == ''
      redirect_to project_path(@project), notice: 'Changes to fields saved.'
    else
      redirect_to "/projects/#{@project.id}/edit_fields", notice: 'Field added'
    end
  end

  def templateUpload
    @project = Project.find(params[:id])
    @options = [['Timestamp', get_field_type('Timestamp')], ['Number', get_field_type('Number')], ['Text', get_field_type('Text')], ['Latitude', get_field_type('Latitude')], ['Longitude', get_field_type('Longitude')]]

    uploader = FileUploader.new
    data_obj = uploader.generateObject(params[:file])
    @types = uploader.get_probable_types(data_obj)
    @tmp_file = data_obj[:file]
    @headers = data_obj['data'].keys

    respond_to do |format|
      format.html
    end
  end

  def finishTemplateUpload
    uploader = FileUploader.new
    @matches = params[:headers]
    @project = Project.find(params[:id])
    @matches.each do |header|
      field = Field.new(project_id: @project.id, field_type: header[1].to_i, name: header[0])

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

    respond_to do |format|
      format.html
    end
  end

  private

  def project_params
    if @cur_user.try(:admin)
      return params[:project].permit(:content, :title, :user_id, :filter, :cloned_from, :has_fields,
         :featured, :is_template, :featured_media_id, :hidden, :featured_at, :lock, :curated,
         :curated_at, :updated_at, :default_vis)
    end

    params[:project].permit(:content, :title, :user_id, :filter, :cloned_from, :has_fields,
      :featured_media_id, :lock, :updated_at, :default_vis)
  end
end
