class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :get_user
  before_filter :authorize
 
  def get_user
    @cur_user = User.find_by_id(session[:user_id])
    @namespace = {action: params[:action], controller: params[:controller]}
    @version = `(git describe --tags) 2>&1`
    @version = "Development Version" if (@version == "" or @version =~ /fatal:/)
  end
  
  def authorize
    unless User.find_by_id(session[:user_id])
      ref = begin
              URI.parse(request.env["HTTP_REFERER"])
            rescue
              URI.parse("http://www.external.com")
            end
         
      if ref.host == request.host
        if ref.path == request.path
          # logout caused a loop, escape!
          redirect_to "/"
        else
          # Refresh with login request
          redirect_to :back, flash: { login_error: "yuup", path: request.path }
        end
      else
        # External referer needs home page to log in
        redirect_to "/", flash: { login_error: "yuup", path: request.path }
      end
    end
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", 
        :layout => false, :status => :not_found }
      format.any  { head :not_found }
    end
  end
end
