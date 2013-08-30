class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.json
  skip_before_filter :authorize, only: [:show,:index]

  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def index
    
    #Main List
    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end
    
    if !params[:per_page].nil?
        pagesize = params[:per_page]
    else
        pagesize = 10;
    end

    
    if params.has_key? "templates_only"
      templates = true
    else
      templates = false
    end
    
    if sort=="ASC" or sort=="DESC"
      @projects = Project.search(params[:search]).paginate(page: params[:page], per_page: pagesize).order("created_at #{sort}").only_templates(templates)
    else
      @projects = Project.search(params[:search]).paginate(page: params[:page], per_page: pagesize).order("like_count DESC").only_templates(templates)
    end

    #Featured list
    @featured_3 = Project.where(featured: true).order("updated_at DESC").limit(3);

    respond_to do |format|
      format.html
      format.json { render json: @projects.map {|p| p.to_hash(false)} }
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

    @data_sets = @project.data_sets.where( 'hidden == ?', false )
    if @data_sets.nil?
      @data_sets = []
    end
    
    recur = params.key?(:recur) ? params[:recur].to_bool : false
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project.to_hash(recur) }
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
      if(!params.try(:[], :project_name))
        @project = Project.new({user_id: @cur_user.id, title:"#{@cur_user.firstname} #{@cur_user.lastname[0].pluralize} Project"})
      else
        @project = Project.new({user_id: @cur_user.id, title: params[:project_name]})
      end
      success = @project.save
    end

    respond_to do |format|
      if success
        format.html { redirect_to @project, notice: 'Project was successfully created.'}
        format.json { render json: @project.to_hash(false), status: :created, location: @project }
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
    editUpdate  = params[:project]
    hideUpdate  = editUpdate.extract_keys!([:hidden])
    adminUpdate = editUpdate.extract_keys!([:featured, :is_template])
    success = false

    #EDIT REQUEST
    if can_edit?(@project)
      success = @project.update_attributes(editUpdate)
    end

    #HIDE REQUEST
    if can_hide?(@project)
      success = @project.update_attributes(hideUpdate)
    end

    #ADMIN REQUEST
    if can_admin?(@project)

      if adminUpdate.has_key?(:featured)
        if adminUpdate['featured'] == "1"
          adminUpdate['featured_at'] = Time.now()
        else
          adminUpdate['featured_at'] = nil
        end
      end

      success = @project.update_attributes(adminUpdate)
    end

    respond_to do |format|
      if success
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors.full_messages(), status: :unprocessable_entity }
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
      @response = count.to_s + " people like this"
    else
      @response = count.to_s + " person likes this"
    end

    respond_to do |format|
      format.json { render json: {update: @response} }
    end
  end

  def importFromIsense
    require 'net/http'

    @pid = params[:pid]
    field_map = {}

    if( !@pid.nil? )

      #Clone existing project from iSENSE
      json = ActiveSupport::JSON.decode(
        Net::HTTP.get(
          URI.parse(
            "http://129.63.8.186/ws/api.php?method=getExperiment&experiment=#{@pid}"
            )
          )
        )

      content = json["data"]["description"] + "<br /><br />Imported from old iSENSE <br />Originally created on #{json['data']['timecreated'].to_time.strftime '%a %b %d %Y'}<br />Click <a href='http://old.isenseproject.org/experiment.php?id=#{@pid}'>here</a> to view the original"
      
      @project = Project.new({user_id: @cur_user.id, title: json["data"]["name"], content: content, featured: json["data"]["featured"]})

      #If clone is successful clone fields
      if @project.save
        json = ActiveSupport::JSON.decode(
          Net::HTTP.get(
            URI.parse(
              "http://129.63.8.186/ws/api.php?method=getExperimentFields&experiment=#{@pid}"
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
          
          field =  Field.create({project_id: @project.id, field_type: type, name: f["field_name"], unit: f["unit_name"]})
          field_map[f["field_id"]] = field
        end

        #Get session list

        json = ActiveSupport::JSON.decode(
          Net::HTTP.get(
            URI.parse("http://129.63.8.186/ws/api.php?method=getSessions&experiment=#{@pid}")
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
              URI.parse("http://129.63.8.186/ws/json.php?sessions=#{ses['id']}")
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
          
          json[0]["fields"].each_with_index do |f, i|
            field = field_map[f["field_id"]]
            header["#{i}"] = { id: "#{field.id}", type: "#{field.field_type}" }
          end
          
          data = Array.new

          json[0]["data"].each do |dr|
            row =  Hash.new
            dr.each_with_index do |d, i|
              if header["#{i}"][:type] == "1"
                begin
                  row[header["#{i}"][:id]] = "U #{Integer d}"
                rescue
                  row[header["#{i}"][:id]] = d
                end
              else
                row[header["#{i}"][:id]] = d
              end
            end
            data.push row
          end
          
          data_set = DataSet.create(user_id: @cur_user.id, project_id: @project.id, title: ses['name'])
          MongoData.create( data_set_id: data_set.id, data: data)

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

    #include FieldHelper

    @project = Project.find params[:id]

    if !params[:save].nil?

      field_list = []

      @project.fields.each do |f|
        field_list.push(f)
      end

      params[:fields][:names].each_with_index do |f, f_index|

        field = Field.create( { name: f, field_type: view_context.get_field_type(params[:fields][:types][f_index]), project_id: @project.id, unit: params[:fields][:units][f_index] } )

        if view_context.get_field_name(field.field_type) == "Latitude"
          field.unit = "deg"
        elsif view_context.get_field_name(field.field_type) == "Longitude"
          field.unit = "deg"
        elsif view_context.get_field_name(field.field_type) == "Text"
          field.unit = ""
        end

        field_list.push field

      end

      @project.fields = field_list
      @project.save!

      respond_to do |format|
        format.json { render json: {project: @project, fields: field_list} }
      end

    else

      require "csv"

      @file = params[:csv]

      if @project.fields.count == 0

        tmp = CSV.read(@file.try(:tempfile))

        col = Array.new
        p_fields = Array.new

        tmp[0].each_with_index do |dp, i|
          col[i] = Array.new
          p_fields[i] = [ "Timestamp", "Number", "Text", "Latitude", "Longitude" ]
        end

        tmp.each_with_index do |row, skip|
          if( skip == 0 )
          else
            row.each_with_index do |data_point, i|
              if( data_point == "" or data_point.nil? )
                col[i].push [ data_point ]
              else
                col[i].push [ data_point.strip() ]
              end
            end
          end
        end

        # TIME TO PULL OUT THE FIELDS THAT DONT MAKE SENSE
        
        col.each_with_index do |c, i|
          c.each do |dp|
            logger.info dp
            if dp[0] != "" and dp[0] != nil
              begin
                f = Float(dp[0])
                
                # Check lat Bounds
                if (f <-90.0 or f > 90.0)
                  p_fields[i][3] = ""
                end
                
                # Check lon Bounds
                if (f <-180.0 or f > 180.0)
                  p_fields[i][4] = ""
                end
                
              rescue
                # Cell is not a number
                p_fields[i][1] = ""
                p_fields[i][3] = ""
                p_fields[i][4] = ""
              end
            end
          end
        end
        
        p_fields.each_with_index do |p, i|

          new_p = Array.new

          p.each do |f|
            if f != ""
              new_p.push f
            end
          end

          p_fields[i] = new_p

        end

        params[:tmp] = Array.new()

        p_fields.each_with_index do |f, i|
          params[:tmp].push Field.new( name: tmp[0][i] )
        end

      end

      respond_to do |format|
        format.json { render json: { action: "template" , pid: @project.id , fields: params[:tmp], p_field_types: p_fields} }
        format.html { redirect_to action: "fieldSelect", id: @project.id }
      end
    end
  end

end