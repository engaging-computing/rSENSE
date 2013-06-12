class MediaObjectsController < ApplicationController
  include ApplicationHelper
  
  # GET /media_objects
  # GET /media_objects.json
  def index
    @media_objects = MediaObject.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @media_objects }
    end
  end

  # GET /media_objects/1
  # GET /media_objects/1.json
  def show
    @media_object = MediaObject.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @media_object }
    end
  end

  # GET /media_objects/new
  # GET /media_objects/new.json
  def new
    @media_object = MediaObject.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @media_object }
    end
  end

  # GET /media_objects/1/edit
  def edit
    @media_object = MediaObject.find(params[:id])
  end

  # POST /media_objects
  # POST /media_objects.json
  def create
    @media_object = MediaObject.new(params[:media_object])

    respond_to do |format|
      if @media_object.save
        format.html { redirect_to @media_object, notice: 'Media object was successfully created.' }
        format.json { render json: @media_object, status: :created, location: @media_object }
      else
        format.html { render action: "new" }
        format.json { render json: @media_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /media_objects/1
  # PUT /media_objects/1.json
  def update
    @media_object = MediaObject.find(params[:id])
    editUpdate  = params[:tutorial].to_hash
    hideUpdate  = editUpdate.extract_keys!([:hidden])
    success = false
    
    #EDIT REQUEST
    if can_edit?(@media_object) 
      success = @media_object.update_attributes(editUpdate)
    end
    
    #HIDE REQUEST
    if can_hide?(@media_object) 
      success = @media_object.update_attributes(hideUpdate)
    end
    
    #ADMIN REQUEST
    if can_admin?(@media_object)
      success = @media_object.update_attributes(adminUpdate)
    end

    respond_to do |format|
      if success
        format.html { redirect_to @media_object, notice: 'MediaObject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @media_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /media_objects/1
  # DELETE /media_objects/1.json
  def destroy
    @media_object = MediaObject.find(params[:id])
    
    if can_delete?(@media_object)
        
      #Set up the link to S3
      s3ConfigFile = YAML.load_file('config/aws_config.yml')
    
      s3 = AWS::S3.new(
        :access_key_id => s3ConfigFile['access_key_id'],
        :secret_access_key => s3ConfigFile['secret_access_key'])
      
      S3Object.delete(@media_object.file_key, 'isenseimgs')
      
      @media_object.destroy

      respond_to do |format|
        format.html { redirect_to media_objects_url }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render status: :forbidden }
      end
    end
  end
  
  #POST /media_object/saveMedia
  def saveMedia
    
    #Figure out where we are uploading data to
    data = params[:keys].split('/')
    target = data[0]
    id = data[1]
    
    #Set up the link to S3
    s3ConfigFile = YAML.load_file('config/aws_config.yml')
    
    s3 = AWS::S3.new(
      :access_key_id => s3ConfigFile['access_key_id'],
      :secret_access_key => s3ConfigFile['secret_access_key'])
    
    #Get our bucket
    bucket = s3.buckets['isenseimgs']

    #Set up the file for upload
    fileKey = (Time.now.strftime "%s") + "." + params[:file].content_type.split("/")[1]
    fileType = params[:file].content_type.split("/")[0]
    filePath = params[:file].tempfile 
    fileName = params[:file].original_filename
    
    if fileType == 'application'
      extended = params[:file].content_type.split("/")[1]
      if extended.include? 'pdf'
        fileType = 'pdf'
      else
        fileType = 'document'
      end
    end
    
    #Generate the key for our file in the bucket
    o = bucket.objects[fileKey]

    #Build media object params based on what we are doing
    case target
    when 'project'
      @project = Project.find_by_id(id)
      if(can_edit?(@project))
        @mo = {user_id: @project.owner.id, project_id: id, src: o.public_url.to_s, name: fileName, media_type: fileType, file_key: fileKey}
      end
    when 'data_set'
      @data_set = DataSet.find_by_id(id)
      if(@data_set.owner == @cur_user)
        @mo = {user_id: @data_set.owner.id, project_id: @data_set.project_id, data_set_id: @data_set.id, src: o.public_url.to_s, name: fileName, media_type: fileType, file_key: fileKey}
      end
    when 'user'
      @user = User.find_by_username(id)
      if(can_edit?(@user))
        @mo = {user_id: @user.id, src: o.public_url.to_s, name: fileName, media_type: fileType, file_key: fileKey}
      end
    when 'tutorial'
      @tutorial = Tutorial.find_by_id(id)
      if(can_edit?(@tutorial))
        @mo = {user_id: @tutorial.owner.id, src: o.public_url.to_s, name: fileName, media_type: fileType, tutorial_id: @tutorial.id, file_key: fileKey}
      end
    when 'visualization'
      @visualization = Visualization.find_by_id(id)
      if(can_edit?(@visualization))
        @mo = {user_id: @visualization.owner.id, src: o.public_url.to_s, name: fileName, media_type: fileType, visualization_id: @visualization.id, file_key: fileKey}
      end
    end

    #If we managed to make some params build the media object and write to S3
    if(defined? @mo)      
    
      #Generate a media object with the calculated params
      MediaObject.create(@mo)
    
      #Write the file to S3
      o.write file: filePath
      
      #Tell redactor where the image is located
      render json: {filelink: o.public_url.to_s, filename: fileName}

    else
      
      #Tell the user there is a problem with uploading their image.
      render json: {filelink: '/assets/noimage.png'}
      
    end
  end
end