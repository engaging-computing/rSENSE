class HomeController < ApplicationController
  skip_before_filter :authorize
  
  def index

      @projects = Project.paginate(per_page: 5, page: params[:page]).order("created_at DESC")
      
      @projects.each do |e|
        e['owner'] = User.find(e.user_id) 
      end
      
      tutorials = Tutorial.where("featured_number IS NOT NULL")
      
      @tutorials = []
      @tutorials[1] = tutorials.where('featured_number == ?',1).first || nil
      @tutorials[2] = tutorials.where('featured_number == ?',2).first || nil
      @tutorials[3] = tutorials.where('featured_number == ?',3).first || nil
      @tutorials[4] = tutorials.where('featured_number == ?',4).first || nil
      
      @all_tutorials = Tutorial.find(:all)
  end
end
