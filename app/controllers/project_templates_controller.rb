class ProjectTemplatesController < ApplicationController

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
      @projects = Project.search(params[:search]).paginate(page: params[:page], per_page: 8).order("created_at #{sort}").is_template
    else
      @projects = Project.search(params[:search]).paginate(page: params[:page], per_page: 8).order("like_count DESC").is_template
    end
  
    respond_to do |format|
      format.html
      format.json { render json: @projects.map {|p| p.to_hash(false)} }
    end
  end
  
end
