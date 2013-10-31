class HomeController < ApplicationController
  skip_before_filter :authorize
  
  def index

    @featured_projects = Project.where("featured = ? and hidden = ?",  true, false).order("featured_at DESC").limit(4)
    @featured_vis = Visualization.where("featured = ? and hidden = ?", true, false).order("featured_at DESC").first
    @curated_projects = Project.where("curated = ? AND hidden = ?", true,false).order("updated_at DESC").limit(4)
  end
  
  def about
    
  end
  
  def contact
    
  end
  
end
