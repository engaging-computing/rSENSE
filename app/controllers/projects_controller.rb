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
    
    @projects.each do |exp|
      
      newJsonObject = {}
      
      newJsonObject["title"]          = exp.title
      newJsonObject["timeAgoInWords"] = time_ago_in_words(exp.created_at)
      newJsonObject["createdAt"]      = exp.created_at.strftime("%B %d, %Y")
      newJsonObject["featured"]       = exp.featured
      newJsonObject["ownerName"]      = "#{exp.owner.name}"
      newJsonObject["projectPath"] = project_path(exp)
      newJsonObject["ownerPath"]      = user_path(exp.owner)
      newJsonObject["filters"]        = exp.filter
      
      if(exp.featured_media_id != nil) 
        newJsonObject["mediaPath"] = MediaObject.find_by_id(exp.featured_media_id).src;
      end
      
      jsonObjects = jsonObjects << newJsonObject
      
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
      format.json { render json: {exp: @project, ses: @project.data_sets} }
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
      @tmp_exp = Project.find(params[:project_id])
      @project = Project.new({user_id: @cur_user.id, title:"#{@tmp_exp.title} (clone)", content: @tmp_exp.content, filter: @tmp_exp.filter, cloned_from:@tmp_exp.id})
      success = @project.save
      @tmp_exp.fields.all.each do |f|
        Field.create({project_id:@project.id, field_type: f.field_type, name: f.name, unit: f.unit})
      end
    else
      @project = Project.new({user_id: @cur_user.id, title:"#{@cur_user.firstname} #{@cur_user.lastname[0].pluralize} Project"})
      success = @project.save
    end

    respond_to do |format|
      if success
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
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

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /projects/eid/fid
  def checkFieldName

    @project = Project.find(params[:eid])
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
  
end