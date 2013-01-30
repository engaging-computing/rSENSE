class HomeController < ApplicationController
  skip_before_filter :authorize
  
  def index

      @experiments = Experiment.paginate(per_page: 5, page: params[:page]).order("created_at DESC")
      
      @experiments.each do |e|
        e['owner'] = User.find(e.user_id) 
      end
  
  end
end
