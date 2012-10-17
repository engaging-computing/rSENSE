class HomeController < ApplicationController
  skip_before_filter :authorize
  
  
  
  def index
      @experiments = Experiment.order("created_at DESC").all
  
      @experiments.each do |e|
        e['owner'] = User.find(e.user_id) 
      end
  
  end
end
