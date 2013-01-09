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



end
