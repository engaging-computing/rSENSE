class MediaObjectsController < ApplicationController
  include ApplicationHelper

  # Allow images to be shown without authentication
  skip_before_filter :authorize, only: [:show]

  # GET /media_objects/1
  # GET /media_objects/1.json
  def show
    @media_object = MediaObject.find(params[:id])

    recur = params.key?(:recur) ? params[:recur] : false

    respond_to do |format|
      format.html
      format.json { render json: @media_object.to_hash(recur), status: :ok }
    end
  end

  # PUT /media_objects/1
  # PUT /media_objects/1.json
  def update
    @media_object = MediaObject.find(params[:id])

    respond_to do |format|
      if can_edit?(@media_object) && @media_object.update_attributes(media_object_params)
        format.html { redirect_to @media_object, notice: 'Media Object was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        @media_object.errors[:base] << 'Permission denied' unless can_edit?(@media_object)
        format.html { redirect_to @media_object, alert: 'Media Object not successfully updated.' }
        format.json { render json: @media_object.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_objects/1
  # DELETE /media_objects/1.json
  def destroy
    @media_object = MediaObject.find(params[:id])

    if can_delete?(@media_object)

      if !@media_object.project_id.nil? && @media_object.project.featured_media_id == @media_object.id
        @media_object.project.featured_media_id = nil
        @media_object.project.save
      end

      if !@media_object.visualization_id.nil? && @media_object.visualization.featured_media_id == @media_object.id
        @media_object.visualization.featured_media_id = nil
        @media_object.visualization.save
      end

      @media_object.destroy

      respond_to do |format|
        format.html do
          redirect_to :back, notice: "Deleted #{@media_object.name}"
        end
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end

  # POST /media_object/saveMedia
  def saveMedia
    extension = params[:upload].original_filename.split('.')[-1]
    unless FileUploader.upload_whitelist.include? extension.downcase
      if params.key?(:non_wys)
        redirect_to :back, flash: { error: "Sorry, #{extension} is not a supported file type." }
        return
      else
        render text: "Sorry, #{extension} is not a supported file type."
        return
      end
    end

    # Figure out where we are uploading data to
    data = params[:keys].split('/')
    target = data[0]
    id = data[1]

    # Set up the file for upload
    file_type = params[:upload].content_type.split('/')[0]
    file_path = params[:upload].tempfile
    file_name = params[:upload].original_filename

    if file_type == 'application'
      extended = params[:upload].content_type.split('/')[1]
      if extended.include? 'pdf'
        file_type = 'pdf'
      else
        file_type = 'document'
      end
    end

    # Rotate based on EXIF data, then strip it out.
    if file_type == 'image'
      fix_rot = MiniMagick::Image.read(file_path)
      unless file_name.include? 'svg'
        fix_rot.auto_orient
      end
      file_path = '/tmp/' + SecureRandom.hex
      File.open(file_path, 'wb') do |ff|
        fix_rot.write ff
      end
    end
    adjust_file_name = file_name.gsub ' ', '_'
    @mo = MediaObject.new
    @mo.name = @mo.file = adjust_file_name
    @mo.media_type = file_type

    # Build media object params based on what we are doing
    case target
    when 'project'
      @project = Project.find_by_id(id) || nil
      if can_edit?(@project)
        @mo.user_id = @project.owner.id
        @mo.project_id = @project.id
      else
        @errors = 'Either you do not have access to this project, or it does not exist.'
      end
    when 'data_set'
      @data_set = DataSet.find_by_id(id) || nil
      if can_edit?(@data_set)
        @mo.user_id = @data_set.owner.id
        @mo.data_set_id = @data_set.id
        @mo.project_id = @data_set.project_id
      else
        @errors = 'Either you do not have access to this data set, or it does not exist.'
      end
    when 'user'
      @user = User.find_by_id(id) || nil
      if can_edit?(@user)
        @mo.user_id = @user.id
      else
        @errors = 'Either you are not the user, or it does not exist.'
      end
    when 'tutorial'
      @tutorial = Tutorial.find_by_id(id) || nil
      if can_edit?(@tutorial)
        @mo.user_id = @tutorial.owner.id
        @mo.tutorial_id = @tutorial.id
      else
        @errors = 'Either you do not have access to this tutorial, or it does not exist.'
      end
    when 'visualization'
      @visualization = Visualization.find_by_id(id) || nil
      if can_edit?(@visualization)
        @mo.user_id = @visualization.owner.id
        @mo.visualization_id = @visualization.id
      else
        @errors = 'Either you do not have access to this visualization, or it does not exist.'
      end
    when 'news'
      @news = News.find_by_id(id) || nil
      if can_edit?(@news)
        @mo.user_id = @news.owner.id
        @mo.news_id = @news.id
      else
        @errors = 'Either you do not have access to this news item, or it does not exist.'
      end
    end

    # If we managed to make some params build the media object
    if !@mo.user_id.nil?
      # Save the file
      @mo.check_store!
      FileUtils.cp(file_path, @mo.file_name)
      File.chmod(0644, @mo.file_name)
      @mo.add_tn

      # Generate a media object with the calculated params
      if @mo.save
        if params.key?(:non_wys)
          respond_to do |format|
            format.html { redirect_to params[:non_wys] }
            format.json { render json: @mo.to_hash(false) }
          end
        else
          # render default
        end
      else
        flash[:error] = @mo.errors.full_messages
        redirect_to :back
        #render text: 'File upload failed'
      end
    else
      # Tell the user there is a problem with uploading their image.
      respond_to do |format|
        format.json { render json: { filelink: '/assets/noimage.png', msg: @errors }, status: :unprocessable_entity }
      end
    end
  end

  private

  def media_object_params
    params[:media_object].permit(:project_id, :media_type, :name, :data_set_id, :src, :user_id, :tutorial_id,
      :visualization_id, :title, :tn_src, :news_id)
  end
end
