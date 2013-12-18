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
      redirect_to "/login"
    end
  end

  def authorize_allow_key
    return if User.find_by_id(session[:user_id])

    proj = Project.find_by_id(params[:id] || params[:pid])
    return if proj && session[:student_access].to_i == proj.id

    dset = DataSet.find_by_id(params[:id])
    return if dset && session[:student_access].to_i == dset.project.id

    redirect_to "/login"
  end

  def authorize_admin
    begin
        if @cur_user.admin == true
            return true
        end
    rescue
    end
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404",
        :layout => false, :status => :not_found }
      format.any  { head :not_found }
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
