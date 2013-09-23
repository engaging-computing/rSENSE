class HomeController < ApplicationController
  skip_before_filter :authorize
  
  def index

    @featured_projects = Project.where("featured = ? and hidden = ?",  true, false).order("featured_at DESC").limit(10)
    @featured_vis = Visualization.where("featured = ? and hidden = ?", true, false).order("featured_at DESC").first
    
  end
  
  def about
    
  end
  
  def contact
    
  end
  
end
