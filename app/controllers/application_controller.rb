class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :get_user
  before_filter :authorize

  
  
  def get_user
      @cur_user = User.find_by_id(session[:user_id])
  end
  
  def authorize
     unless User.find_by_id(session[:user_id])
         redirect_to login_url, notice: "Please log in"
     end
  end
end
