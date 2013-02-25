class ExperimentTemplatesController < ApplicationController

  skip_before_filter :authorize, only: [:show,:index]  

  def index
    
    #Main List
    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end
    
    if sort=="ASC" or sort=="DESC"
      @experiments = Experiment.filter(params[:filters]).search(params[:search]).paginate(page: params[:page], per_page: 8).order("created_at #{sort}").is_template
    else
      @experiments = Experiment.filter(params[:filters]).search(params[:search]).paginate(page: params[:page], per_page: 8).order("like_count DESC").is_template
    end
  end

  
  #Featured list
  @featured_3 = Experiment.where(featured: true).order("updated_at DESC").limit(3);
  
  jsonExperiments = []
  
  @experiments.each do |exp|
    
    newJsonExperiment = {}
    
    newJsonExperiment["title"]          = exp.title
    newJsonExperiment["timeAgoInWords"] = time_ago_in_words(exp.created_at)
    newJsonExperiment["createdAt"]      = exp.created_at.strftime("%B %d, %Y")
    newJsonExperiment["featured"]       = exp.featured
    newJsonExperiment["ownerName"]      = "#{exp.owner.firstname} #{exp.owner.lastname}"
    newJsonExperiment["experimentPath"] = experiment_path(exp)
    newJsonExperiment["ownerPath"]      = user_path(exp.owner)
    newJsonExperiment["filters"]        = exp.filter
    
    if(exp.featured_media_id != nil) 
      newJsonExperiment["mediaPath"] = MediaObject.find_by_id(exp.featured_media_id).src;
    end
    
    jsonExperiments = jsonExperiments << newJsonExperiment
    
  end
  
  respond_to do |format|
    format.html
    format.json { render json: jsonExperiments }
  end


end
