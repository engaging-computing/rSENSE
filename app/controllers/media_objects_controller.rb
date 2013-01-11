class MediaObjectsController < ApplicationController
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

    respond_to do |format|
      if @media_object.update_attributes(params[:media_object])
        format.html { redirect_to @media_object, notice: 'Media object was successfully updated.' }
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
    @media_object.destroy

    respond_to do |format|
      format.html { redirect_to media_objects_url }
      format.json { head :no_content }
    end
  end
  
  #POST /media_object/saveimage
  def saveimage
    logger.info"askljdfalksdjf;lkasdjf;lkasjdf;lasjdf;lfajsddf;lkasjdf;lkajsd;flkkjas;ldkfja;lksdjf;lkas"
    #Figure out where we are uploading data to
    data = params[:keys].split('/')
    type = data[0]
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
    filePath = params[:file].tempfile 

    #Generate the key for our file in the bucket
    o = bucket.objects[fileKey]

    #Build media object params based on what we are doing
    case type
    when 'experiment'
      @experiment = Experiment.find_by_id(id)
      if(@experiment.owner == @cur_user)
        @mo = {user_id: @experiment.owner.id, experiment_id: id, src: o.public_url.to_s, name: @experiment.title + " image"}
      end
    when 'experiment_session'
      @experiment_session = ExperimentSession.find_by_id(id)
      if(@experiment_session.owner == @cur_user)
        @mo = {user_id: @experiment_session.owner.id, experiment_id: @experiment_session.experiment_id, session_id: @experiment_session.id, src: o.public_url.to_s, name: @experiment_session.title + " image"}
      end
    when 'user'
      @user = User.find_by_username(id)
      if(@user==@cur_user)
        @mo = {user_id: @user.id, src: o.public_url.to_s, name: @user.name.pluralize + " image"}
      end
    end

    #If we managed to make some params build the media object and write to S3
    if(defined? @mo)      
    
      #Generate a media object with the calculated params
      MediaObject.create(@mo)
    
      #Write the file to S3
      o.write file: filePath
      
      #Tell redactor where the image is located
      render json: {filelink: o.public_url.to_s}

    else
      
      #Tell the user there is a problem with uploading their image.
      render json: {filelink: '/assets/noimage.png'}
      
    end
  end
end