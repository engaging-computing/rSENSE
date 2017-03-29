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
      pagesize = 48
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

    @cloned_project = Project.select(:id, :user_id, :title).where(id: @project.cloned_from).first
    @liked_by_cur_user = Like.find_by_user_id_and_project_id(current_user, @project.id)
    @data_sets = @project.data_sets.includes(:user).select('id', 'title', 'user_id', 'key', 'created_at', 'contributor_name').search(params[:search])
    @fields = @project.fields
    @field_count = @fields.count
    @formula_fields = @project.formula_fields
    @formula_field_count = @formula_fields.count
    @data_set_count = @data_sets.length

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
      @project = cloned_from.clone(params, current_user.id)
    else
      @cloned_project = nil
      @project = Project.new project_params
      @project.user_id = current_user.id
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
    # If the user hit the "Reset Defaults" button, set globals to nil.
    # nil can't be passed from the url, so do it here.
    update[:globals] = nil if update[:globals] == ''

    # ADMIN REQUEST
    if current_user.try(:admin)
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
        format.html { render action: 'show' }
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
    begin
      @project = Project.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.json { render json: { error: 'Project not found.' }, status: :not_found }
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

    unless can_delete?(@project)
      respond_to do |format|
        format.html { redirect_to '/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
      return
    end

    @project.media_objects.each(&:destroy)

    Project.where('cloned_from = ?', @project.id).each do |clone|
      clone.cloned_from = nil
      clone.save!
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
    like = Like.find_by_user_id_and_project_id(current_user, params[:id])

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
      if Like.create(user_id: current_user.id, project_id: params[:id])
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
    @fields = @project.fields
    @allowable_types = [:timestamp, :number, :text, :location]
    @action = 'fields'
    @can_delete = @project.data_sets.count == 0
  end

  def edit_formula_fields
    @project = Project.find(params[:id])
    @fields = @project.formula_fields.sort { |l, r| l.index <=> r.index }
    @allowable_types = [:number, :text]
    @action = 'formula_fields'
    @can_delete = true

    fields_sorted = @project.fields.sort { |a, b| a.index <=> b.index }
    @field_refs = fields_sorted.map do |f|
      type = case f.field_type
             when 1 then 'Timestamp'
             when 2 then 'Number'
             when 3 then 'Text'
             when 4 then 'Latitude'
             when 5 then 'Longitude'
             end
      [f.name, f.refname, type]
    end

    render 'edit_fields'
  end

  # Save fields in fields table
  def save_fields
    @project = Project.find(params[:id])

    errors = []
    success = true

    ActiveRecord::Base.transaction do
      if params[:hidden_deleted_fields].length != 0
        if @project.data_sets.length > 0
          respond_to do |format|
            format.html do
              redirect_to [:show, @project],
              alert: "Can't delete fields when you have existing data sets."
            end
            format.json { render json: { errors: ["Can't delete fields when you have existing data sets. Delete existing data sets and try again."] }, status: :forbidden }
          end
          return
        end
        delete_hidden_fields(Field, params[:hidden_deleted_fields])
      end

      # Update existing fields, create restrictions if any exist
      @project.fields.each do |field|
        errors += update_field(field, params)
      end

      # Add fields based on type
      errors += add_location_field(params)
      errors += add_timestamp_field(params)
      errors += add_number_fields(params)
      errors += add_text_fields(params)

      # If there's recorded error messages, roll back the database
      if errors.length != 0
        success = false
        fail ActiveRecord::Rollback
      end
    end

    # Don't recalculate anything if we ended up rolling back, because nothing changed
    if success
      @project.reload
      @project.recalculate_data_sets
    end

    # redirect_to "/projects/#{@project.id}", notice: 'Fields were successfully updated.'
    respond_to do |format|
      if success
        response = { redirect: url_for(@project) }
        format.json { render json: response,  status: :ok }
      else
        response = { errors: errors.uniq }
        format.json { render json: response,  status: :unprocessable_entity }
      end
    end
  end

  def save_formula_fields
    @project = Project.find(params[:id])

    errors = []
    success = true

    ActiveRecord::Base.transaction do
      delete_hidden_fields(FormulaField, params[:hidden_deleted_fields])

      # Update existing fields, create restrictions if any exist
      @project.formula_fields.each do |field|
        errors += update_formula_field(field, params)
        # do formula validation here
      end

      # Add fields based on type
      errors += add_number_formula_fields(params)
      errors += add_text_formula_fields(params)

      # so we can validate the formulas
      @project.reload

      # check the formulas for validity
      # put the fields and formula fields in a format usable by the checker
      check_fields = @project.fields.map do |x|
        type = [nil, [:timestamp], [:number], [:text], [:latitude], [:longitude]][x.field_type]
        [x.refname, type]
      end
      formulas_sorted = @project.formula_fields.sort { |a, b| a.index <=> b.index }
      check_formulas = formulas_sorted.map do |x|
        type = [nil, nil, [:number], [:text]][x.field_type]
        [x.refname, type, x.formula, x.name]
      end
      # try and run the formulas on a dummy environment and see if they work
      errors += FormulaField.try_execute(check_formulas, check_fields)

      # If there's recorded error messages, roll back the databases
      if errors.length != 0
        success = false
        fail ActiveRecord::Rollback
      end
    end

    # Don't recalculate anything if we ended up rolling back, because nothing changed
    if success
      @project.reload
      @project.recalculate_data_sets
    end

    # redirect_to "/projects/#{@project.id}", notice: 'Formula fields were successfully updated.'
    respond_to do |format|
      if success
        response = { redirect: url_for(@project) }
        format.json { render json: response, status: :ok }
      else
        response = { errors: errors.uniq }
        format.json { render json: response, status: :unprocessable_entity }
      end
    end
  end

  def templateUpload
    @project = Project.find(params[:id])
    @options = [['Timestamp', get_field_type('Timestamp')],
                ['Number', get_field_type('Number')],
                ['Text', get_field_type('Text')],
                ['Latitude', get_field_type('Latitude')],
                ['Longitude', get_field_type('Longitude')]]

    if params[:file].size > 10000000
      redirect_to @project, alert: 'Maximum upload size of a single data set is 10 MB. Please split your file into multiple pieces and upload them individually.'
      return
    end

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
    fields = []
    num_timestamps = 0
    @matches.each do |header|
      field = Field.new(project_id: @project.id,
                        field_type: header[1].to_i,
                        name: header[0],
                        index: @project.fields.size)

      if field.field_type == 1 and num_timestamps == 0 then num_timestamps += 1
      elsif field.field_type == 1
        flash[:error] = 'You may only have 1 Timestamp field.'
        redirect_to project_path(@project) and return
      end

      unless field.valid?
        flash[:error] = field.errors.full_messages
        redirect_to project_path(@project) and return
      end
      # Don't save fields until we know they are all valid
      fields.push(field)
    end

    fields.each do |field|
      unless field.save
        flash[:error] = field.errors.full_messages
        redirect_to project_path(@project) and return
      end
    end

    # reload the project here after the fields are added
    # otherwise, @project.fields returns nothing.
    @project = Project.find(params[:id])

    if params.key?('create_dataset')
      data_obj = uploader.retrieve_obj(params[:file])
      data = uploader.swap_with_field_names(data_obj, @project)

      dataset = DataSet.new do |d|
        d.user_id = current_user.id
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

  def create_tag
    tag = Tag.find_or_create_by(name: params[:name].to_s.squish)
    project = Project.find(params[:id])
    unless project.tags.exists?(tag.id)
      project.tags << tag
    end
    project.save!
    respond_to do |format|
      msg = { status: 'ok', message: 'Success!',
             id: tag.id, name: tag.name }
      format.json  { render json: msg }
    end
  end

  def remove_tag
    tag_id = params[:tagId]
    project_id = params[:id]
    tag = Tag.find(tag_id)
    project = Project.find(project_id)
    # deletes association but not tag
    project.tags.delete(tag)
    last_tagging = Tagging.where(tag_id: tag_id).empty?
    if last_tagging
      tag.delete
    end
    respond_to do |format|
      msg = { status: 'ok', message: 'Success!' }
      format.json  { render json: msg }
    end
  end

  private

  # Helper function to delete hidden fields
  def delete_hidden_fields(field_model, hidden_fields_str)
    # Delete fields as necessary
    if hidden_fields_str != ''
      hidden_fields_str.split(',').each do |x|
        if field_model.find(x).destroy == -1 and return
        end
      end
    end
  end

  # Helper function to update individual fields
  def update_field(field, params)
    if params.key?("#{field.id}_restrictions")
      restrictions = params["#{field.id}_restrictions"].split(',')
      if restrictions.count < 1
        restrictions = []
      end
    else
      restrictions = []
    end

    attributes = {
      name: params["#{field.id}_name"],
      unit: params["#{field.id}_unit"],
      restrictions: restrictions,
      index: params["#{field.id}_index"]
    }
    success = field.update_attributes(attributes)

    if success
      []
    else
      field.errors.full_messages
    end
  end

  # Helper function to update individual formula fields
  def update_formula_field(field, params)
    success = field.update_attributes(name: params["#{field.id}_name"],
                                      unit: params["#{field.id}_unit"],
                                      formula: params["#{field.id}_formula"],
                                      index: params["#{field.id}_index"])

    if success
      []
    else
      field.errors.full_messages
    end
  end

  def add_location_field(params)
    if params[:hidden_location_count] != '0'
      errors = []
      errors += add_field('Latitude', params[:latitude], 'deg', [], params['latitude_index'])
      errors += add_field('Longitude', params[:longitude], 'deg', [], params['longitude_index'])
      errors
    else
      []
    end
  end

  def add_timestamp_field(params)
    if params[:hidden_timestamp_count] == '1'
      add_field('Timestamp', params[:timestamp], '', [], params['timestamp_index'])
    else
      []
    end
  end

  def add_number_fields(params)
    errors = []
    (params[:hidden_num_count].to_i).times do |i|
      errors += add_field('Number', params[('number_' + (i + 1).to_s).to_sym], params[('units_' + (i + 1).to_s).to_sym], [],  params[('number_' + ((i + 1).to_s) + '_index').to_sym])
    end
    errors
  end

  def add_text_fields(params)
    errors = []
    (params[:hidden_text_count].to_i).times do |i|
      # Need to explicitly check if restrictions are nil because empty restrictions should be []
      restrictions = params[('restrictions_' + (i + 1).to_s).to_sym].nil? ? [] : params[('restrictions_' + (i + 1).to_s).to_sym].split(',')
      errors += add_field('Text', params[('text_' + (i + 1).to_s).to_sym], '', restrictions, params[('text_' + (i + 1).to_s + '_index').to_sym])
    end
    errors
  end

  def add_number_formula_fields(params)
    errors = []
    (params[:hidden_num_count].to_i).times do |i|
      field_name = params[('number_' + (i + 1).to_s).to_sym]
      units = params[('units_' + (i + 1).to_s).to_sym]
      formula = params[('nformula_' + (i + 1).to_s).to_sym]
      index = params[('number_' + ((i + 1).to_s) + '_index').to_sym]
      errors += add_formula_field('Number', field_name, units, formula, index)
    end
    errors
  end

  def add_text_formula_fields(params)
    errors = []
    (params[:hidden_text_count].to_i).times do |i|
      field_name = params[('text_' + (i + 1).to_s).to_sym]
      formula = params[('tformula_' + (i + 1).to_s).to_sym]
      index = params[('text_' + (i + 1).to_s + '_index').to_sym]
      errors += add_formula_field('Text', field_name, '', formula, index)
    end
    errors
  end

  # Helper function to add field to database
  def add_field(field_type, field_name, unit, restrictions, index)
    if field_name.nil?
      []
    else
      if index.nil?
        index = @project.fields.size
      end
      field = Field.new(project_id: @project.id,
                        field_type: get_field_type(field_type),
                        name: field_name,
                        unit: unit,
                        restrictions: restrictions,
                        index: index)
      field.save ? [] : field.errors.full_messages
    end
  end

  # Helper function to add field to database
  def add_formula_field(field_type, field_name, unit, formula, index)
    if field_name.nil?
      []
    else
      if index.nil?
        index = @project.fields.size
      end
      field = FormulaField.new(project_id: @project.id,
                               field_type: get_field_type(field_type),
                               name: field_name,
                               unit: unit,
                               formula: formula,
                               index: index)
      field.save ? [] : field.errors.full_messages
    end
  end

  def project_params
    if current_user.try(:admin)
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
