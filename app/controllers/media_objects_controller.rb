
class MediaObjectsController < ApplicationController
  include ApplicationHelper

  # Allow images to be shown without authentication
  skip_before_filter :authorize, :only => [:show]

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
        format.json { render json:{}, status: :ok }
      else
        @media_object.errors[:base] << "Permission denied" unless can_edit?(@media_object)
        format.html { redirect_to @media_object, alert: 'Media Object not successfully updated.' }
        format.json { render json: @media_object.errors.full_messages(), status: :unprocessable_entity }
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
      
      @media_object.destroy

      respond_to do |format|
        format.html do
          if request.env["HTTP_REFERER"]
            redirect_to :back, notice: "Deleted #{@media_object.name}" 
          else
            redirect_to media_objects_path, notice: "Deleted #{@media_object.name}" 
          end
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
  
  #POST /media_object/saveMedia
  def saveMedia
    #Figure out where we are uploading data to
    data = params[:keys].split('/')
    target = data[0]
    id = data[1]

    #Set up the file for upload
    fileType = params[:upload].content_type.split("/")[0]
    filePath = params[:upload].tempfile 
    fileName = params[:upload].original_filename

    if fileType == 'application'
      extended = params[:upload].content_type.split("/")[1]
      if extended.include? 'pdf'
        fileType = 'pdf'
      else
        fileType = 'document'
      end
    end
    
    # Rotate based on EXIF data, then strip it out.
    if fileType == 'image'
      fixRot = MiniMagick::Image.read(filePath)
      fixRot.auto_orient
      fixRot.strip
      fixRot.write filePath
    end
    
    @mo = MediaObject.new
    @mo.name = fileName
    @mo.media_type = fileType
    
    #Build media object params based on what we are doing
    case target
    when 'project'
      @project = Project.find_by_id(id)
      if(can_edit?(@project))
        @mo.user_id = @project.owner.id
        @mo.project_id = @project.id
      end
    when 'data_set'
      @data_set = DataSet.find_by_id(id)
      if(can_edit?(@data_set))
        @mo.user_id = @data_set.owner.id
        @mo.data_set_id = @data_set.id
        @mo.project_id = @data_set.project_id
      end
    when 'user'
      @user = User.find_by_id(id)
      if(can_edit?(@user))
        @mo.user_id = @user.id
      end
    when 'tutorial'
      @tutorial = Tutorial.find_by_id(id)
      if(can_edit?(@tutorial))
        @mo.user_id = @tutorial.owner.id 
        @mo.tutorial_id = @tutorial.id
      end
    when 'visualization'
      logger.error 'in visualizaiton' 
      @visualization = Visualization.find_by_id(id)
      if(can_edit?(@visualization))
        @mo.user_id = @visualization.owner.id
        @mo.visualization_id = @visualization.id
      end
    when 'news'
      @news = News.find_by_id(id)
      if(can_edit?(@news))
        @mo.user_id = @news.owner.id
        @mo.news_id = @news.id
      end
    end

    #If we managed to make some params build the media object
    unless @mo.user_id.nil?
      # Save the file
      @mo.check_store!

      FileUtils.cp(filePath, @mo.file_name)
      File.chmod(0644, @mo.file_name)

      @mo.add_tn

      # Generate a media object with the calculated params
      if @mo.save
        if params.has_key?(:non_wys)
          respond_to do |format|
            format.html { redirect_to params[:non_wys] }
            format.json { render json: @mo.to_hash(false) }
          end
        else
          # render default
        end
      else
        render text: "File upload failed"
        logger.info "Error saving Media Object"
        logger.info @mo.errors.inspect
      end
      
    else
      #Tell the user there is a problem with uploading their image.
      render json: {filelink: '/assets/noimage.png'}
    end
  end

  private

  def media_object_params
    params[:media_object].permit(:project_id, :media_type, :name, :data_set_id, :src, :user_id, :tutorial_id, 
      :visualization_id, :title, :tn_src, :news_id)
  end
end
