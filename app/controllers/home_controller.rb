class HomeController < ApplicationController
  skip_before_filter :authorize
  
  def index

    @featured_projects = Project.where("featured == ?",true).order("featured_at DESC").limit(3)

    tutorials = Tutorial.where("featured_number IS NOT NULL")
    
    @tutorials = []
    @tutorials[1] = tutorials.where('featured_number == ?',1).first || nil
    @tutorials[2] = tutorials.where('featured_number == ?',2).first || nil
    @tutorials[3] = tutorials.where('featured_number == ?',3).first || nil
    @tutorials[4] = tutorials.where('featured_number == ?',4).first || nil
    
    @all_tutorials = Tutorial.find(:all)
  end
end
