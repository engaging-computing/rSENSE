class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.json
  skip_before_filter :authorize, only: [:show,:index]

  include ActionView::Helpers::DateHelper

  def index

    #Main List
    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end

    if sort=="ASC" or sort=="DESC"
      @projects = Project.filter(params[:filters]).search(params[:search]).paginate(page: params[:page], per_page: 100).order("created_at #{sort}")
    else
      @projects = Project.filter(params[:filters]).search(params[:search]).paginate(page: params[:page], per_page: 100).order("like_count DESC")
    end

    #Featured list
    @featured_3 = Project.where(featured: true).order("updated_at DESC").limit(3);

    jsonObjects = []

    @projects.each do |proj|
      if(!proj.hidden)
        newJsonObject = {}

        newJsonObject["title"]          = proj.title
        newJsonObject["timeAgoInWords"] = time_ago_in_words(proj.created_at)
        newJsonObject["createdAt"]      = proj.created_at.strftime("%B %d, %Y")
        newJsonObject["featured"]       = proj.featured
        newJsonObject["ownerName"]      = "#{proj.owner.name}"
        newJsonObject["projectPath"] = project_path(proj)
        newJsonObject["ownerPath"]      = user_path(proj.owner)
        newJsonObject["filters"]        = proj.filter

        if(proj.featured_media_id != nil)
          newJsonObject["mediaPath"] = MediaObject.find_by_id(proj.featured_media_id).src;
        end

        jsonObjects = jsonObjects << newJsonObject
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: jsonObjects }
    end

  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])

    #Determine if the project is cloned
    @cloned_project = nil
    if(!@project.cloned_from.nil?)
      @cloned_project = Project.find(@project.cloned_from)
    end

    #Get number of likes
    @likes = @project.likes.count

    @liked_by_cur_user = false
    if(Like.find_by_user_id_and_project_id(@cur_user,@project.id))
      @liked_by_cur_user = true
    end

    #checks for fields
    @has_fields = false
    if( @project.fields.count > 0)
      @has_fields = true
    end



    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: {proj: @project, ses: @project.data_sets} }
    end
  end

  def createSession

    @project = Project.find(params[:id])

  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.json
  def create
    #@project = Project.new(params[:project])

    if(params[:project_id])
      @tmp_proj = Project.find(params[:project_id])
      @project = Project.new({user_id: @cur_user.id, title:"#{@tmp_proj.title} (clone)", content: @tmp_proj.content, filter: @tmp_proj.filter, cloned_from:@tmp_proj.id})
      success = @project.save
      @tmp_proj.fields.all.each do |f|
        Field.create({project_id:@project.id, field_type: f.field_type, name: f.name, unit: f.unit})
      end
    else
      @project = Project.new({user_id: @cur_user.id, title:"#{@cur_user.firstname} #{@cur_user.lastname[0].pluralize} Project"})
      success = @project.save
    end

    respond_to do |format|
      if success
        format.html { redirect_to @project, notice: 'Project was successfully created.'}
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1s
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])

    ps = params[:project]

    if ps.has_key?(:featured)
      if ps['featured'] == "1"
        ps['featured_at'] = Time.now()
      else
        ps['featured_at'] = nil
      end
    end

    respond_to do |format|
      if @project.update_attributes(ps)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /projects/pid/fid
  def checkFieldName

    @project = Project.find(params[:pid])
    orig = true

    @project.fields.all.each do |f|
      if f.id != params[:fid].to_i
        if f.name == params['field']['name']
          orig = false
        end
      end
    end

    respond_to do |format|
      format.json { render json: {orig: orig} }
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end


  def updateLikedStatus

    like = Like.find_by_user_id_and_project_id(@cur_user,params[:id])

    if(like)
      Like.destroy(like.id)
    else
      Like.create({user_id:@cur_user.id,project_id:params[:id]})
    end

    count = Project.find(params[:id]).likes.count

    Project.find(params[:id]).update_attributes(:like_count => count)

    if(count == 0 || count > 1)
      @response = count.to_s + " people liked this"
    else
      @response = count.to_s + " person liked this"
    end

    respond_to do |format|
      format.json { render json: {update: @response} }
    end
  end

  def removeField

    @project = Project.find(params[:id])

    msg = ""

    if @project.data_sets.count == 0

      field_list = []

      @project.fields.each do |f|
        if f.id != params[:field_id].to_i
          field_list.push(f)
        end
      end

    @project.fields = field_list
    @project.save!

    end

    respond_to do |format|
      format.json { render json: {project: @project, fields: field_list} }
    end

  end

  def importFromIsense
    require 'net/http'

    @pid = params[:pid]

    if( !@pid.nil? )

      #Clone existing project from iSENSE
      json = ActiveSupport::JSON.decode(
        Net::HTTP.get(
          URI.parse(
            "http://isenseproject.org/ws/api.php?method=getExperiment&experiment=#{@pid}"
            )
          )
        )

      @project = Project.new({user_id: @cur_user.id, title: json["data"]["name"], content: json["data"]["description"], featured: json["data"]["featured"]})

      #If clone is successful clone fields
      if @project.save
        json = ActiveSupport::JSON.decode(
          Net::HTTP.get(
            URI.parse(
              "http://isenseproject.org/ws/api.php?method=getExperimentFields&experiment=#{@pid}"
            )
          )
        )

        #For each field append it to the project's field list
        json["data"].each do |f|
          if f["type_id"].to_i == 7
            type = 1
          elsif f["type_id"].to_i == 37
            type = 3
          elsif f["type_id"].to_i == 19
            if f["unit_name"].downcase == "latitude"
              type = 4
            else
              type = 5
            end
          else
            type = 2
          end
          @project.fields.push Field.create({project_id: @project.id, field_type: type, name: f["field_name"], unit: f["unit_name"]})
        end

        #Get session list

        json = ActiveSupport::JSON.decode(
          Net::HTTP.get(
            URI.parse("http://isenseproject.org/ws/api.php?method=getSessions&experiment=#{@pid}")
          )
        )

        sessions = Array.new()

        json["data"].each do |ses|
          sessions.push Hash["id" => ses["session_id"].to_s, "name" => ses["name"].to_s, "desc" => ses["description"].to_s ]
        end

        params[:pid] = @project.id

        retry_attempts = 5

        #Get the data from each session
        sessions.each_with_index do |ses, ses_index|

          begin

            response = Net::HTTP.get(
              URI.parse("http://isenseproject.org/ws/json.php?sessions=#{ses['id']}")
            )

          rescue SocketError => error
            if retry_attempts > 0
              retry_attempts -= 1
              sleep 5
              retry
            end

            raise
          end

          response["var DATA = "] = ""
          response["var STATE = \"\""] = ""

          while( response[";"] )
            response[";"] = ""
          end

          json = ActiveSupport::JSON.decode response

          header = Hash.new

          @project.fields.all.each_with_index do |f, i|
            header["#{i}"] = { id: "#{f.id}", type: "#{f.field_type}" }
          end

          data = Hash.new

          json[0]["data"].each_with_index do |d, i|
            data["#{i}"] = d
          end

          DataSet.upload_form(header, data, @cur_user, @project, ses['name'])

        end

        redirect_to @project
      else

        logger.info "The project didn't save for some reason..."

      end


    else
      respond_to do |format|
        format.json { render json: json }
        format.html
      end
    end

  end

  
  def templateFields

    require "csv"

    @file = params[:csv]
    @project = Project.find params[:id]
    
    if @project.fields.count == 0
    
      tmp = CSV.read(@file.tempfile)
      
      col = Array.new
      p_fields = Array.new
      
      
      
      tmp[0].each_with_index do |dp, i|
        col[i] = Array.new
        p_fields[i] = { t: "Timestamp", n: "Number", s: "String", l: "Location" }
      end
      
      tmp.each_with_index do |row, skip|
        if( skip == 0 )
        else
          row.each_with_index do |data_point, i|
            col[i].push [ data_point.strip() ]
          end
        end
      end
      
      col.each_with_index do |c, i|
        c.each do |dp|
          if( dp[0] != "")
            if( dp[0].to_i == 0 and dp[0] != "0" )
              p_fields[i][:n] = ""
              p_fields[i][:l] = ""
            end
            
            if( dp[0].to_f > 180 or dp[0].to_f < -180 )
              p_fields[i][:l] = ""
            end
            
            if( dp[0].to_i.to_f.to_s != dp[0].to_f.to_s )
              p_fields[i][:t] = ""
            end
          end
        end
      end
      
      params[:tmp] = Hash.new()
      
      p_fields.each_with_index do |f, i|
        params[:tmp] = Field.new( project_id: @project.id, name: tmp[0][i] )
      end
      
    end
    
    respond_to do |format|
      format.json { render json: {p_field_types: p_fields} }
      format.html { redirect_to action: "fieldSelect", id: @project.id }
    end
  
  end
  
  def fieldSelect
  
    @project = Project.find(params[:id])
    
    if( !params[:createFields].nil? )
    end
    
    respond_to do |format|
      format.json { render json: {fields: [1,2,3]} }
      format.html
    end
  
  end
  
end