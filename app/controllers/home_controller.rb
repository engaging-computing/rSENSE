class HomeController < ApplicationController
  skip_before_filter :authorize
  
  def index

    @featured_projects = Project.where("featured == ? and hidden == ?",  true, false).order("featured_at DESC").limit(3)
    @featured_vis = Visualization.where("featured == ? and hidden == ?", true, false).order("featured_at DESC").first
    tutorials = Tutorial.where("featured_number IS NOT NULL")
    
    @tutorials = []
    @tutorials[1] = tutorials.where('featured_number == ? and hidden == ?',1, false).first || nil
    @tutorials[2] = tutorials.where('featured_number == ? and hidden == ?',2, false).first || nil
    @tutorials[3] = tutorials.where('featured_number == ? and hidden == ?',3, false).first || nil
    @tutorials[4] = tutorials.where('featured_number == ? and hidden == ?',4, false).first || nil
    
    @all_tutorials = Tutorial.find(:all)
  end
end
