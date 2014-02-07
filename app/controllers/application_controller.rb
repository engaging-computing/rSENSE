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
    return if proj && session[:contrib_access].to_i == proj.id

    dset = DataSet.find_by_id(params[:id])
    return if dset && session[:contrib_access].to_i == dset.project.id

    redirect_to "/login"
  end

  def authorize_admin
    begin
        if @cur_user.admin == true
            return true
        end
    rescue
    end
    respond_to do |format|puts 
      format.html { render :file => "#{Rails.root}/public/404",
        :layout => false, :status => :forbidden }
      format.any  { head :forbidden }
    end
  end
  
  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", 
        :layout => false, :status => :not_found }
      format.any  { head :not_found }
    end
  end

  def set_user
    if (params.has_key? :email) & (params.has_key? :password)
      login_email = params[:email].downcase

      @user = User.where("lower(email) = ?", login_email).first

      if @user and @user.authenticate(params[:password])
#         session[:user_id] = @user.id
        @user.update_attributes(:last_login => Time.now())
        @cur_user = @user
      else
        respond_to do |format|
          format.json {render json: {msg: "Email & Password do not match"},status: :unauthorized}
        end
      end
    elsif (params.has_key? :contribution_key) && (['jsonDataUpload','saveMedia'].include? params[:action])
      project = Project.find_by_id(params[:id] || params[:pid])
      if project && !project.contrib_keys.find_by_key(params[:contribution_key]).nil?
        if params.has_key? :contributor_name
          @cur_user = User.find_by_id(project.owner.id)
        else
          respond_to do |format|
            format.json {render json: {msg: "Missing contributor name"},status: :unprocessable_entity}
          end
        end
      else
        respond_to do |format|
          format.json {render json: {msg: "contribution_key not valid"},status: :unauthorized}
        end
      end
    else

      respond_to do |format|
        format.json {render json: {msg: "Must send Email & Password with this request"},status: :unauthorized}
      end
    end
  end

end
