class ExperimentTemplatesController < ApplicationController

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
      @projects = Project.filter(params[:filters]).search(params[:search]).paginate(page: params[:page], per_page: 8).order("created_at #{sort}").is_template
    else
      @projects = Project.filter(params[:filters]).search(params[:search]).paginate(page: params[:page], per_page: 8).order("like_count DESC").is_template
    end
  
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
  
end
