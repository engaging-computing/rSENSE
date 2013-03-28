class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :get_user
  before_filter :authorize
 
  def get_user
      @cur_user = User.find_by_id(session[:user_id])
  end
  
  def authorize
     unless User.find_by_id(session[:user_id])
        
        ref = URI.parse(request.env["HTTP_REFERER"])
         
        if ref.host == request.host
          redirect_to :back, flash: {notice: "LOGIN_ERROR", path: request.path}
        else
          redirect_to "/", flash: {notice: "LOGIN_ERROR", path: request.path}
        end
     end
  end
  
end