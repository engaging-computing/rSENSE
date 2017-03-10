class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :find_user
  before_filter :authorize

  skip_before_filter :verify_authenticity_token, only: [:options_req]
  skip_before_filter :find_user, only: [:options_req]
  skip_before_filter :authorize, only: [:options_req]

  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_out_path_for(_resource_or_scope)
    logger.error "---#{request.referrer}--"
    logger.error "-----------#{params[:controller]}-------------"
    if request.referrer.include? '/users/'
      '/'
    else
      request.referrer
    end
  end

  def after_sign_in_path_for(_resource_or_scope)
    session[:key] = nil
    session[:contributor_name] = nil
    session[:contrib_access] = nil
    # If there was an error creating a user then session[:sign_in_referrer] == localhost:3000/users
    if session[:sign_in_referrer] && !(session[:sign_in_referrer].include? 'users')
      ref = session[:sign_in_referrer]
      session.delete(:sign_in_referrer)
      return ref
    else
      return user_path(current_user)
    end
  end

  def authorize
    # We have a separate sign in page that we dont want to redirect to
    if request.referrer
      unless request.referrer.include? 'sign_in'
        session[:sign_in_referrer] = request.referrer
      end
    end

    if !user_signed_in? && (params[:action] == 'create_issue_anon' || params[:action] == 'github_authorize')
      redirect_to new_user_session_path
      return
    end

    unless user_signed_in? or ['devise/sessions', 'devise/registrations', 'sessions'].include? params[:controller]
      redirect_to '/users/sign_in', flash: { error: 'You are not currently logged in.' }
    end
  end

  def authorize_allow_key
    return if user_signed_in?

    ckey = session[:contrib_access].to_i

    proj = Project.find_by_id(params[:id] || params[:pid] || params[:data_set][:project_id])
    return if proj && proj.id == ckey

    dset = DataSet.find_by_id(params[:id])
    return if dset && ckey == dset.project.id

    redirect_to new_user_session_path
  end

  def authorize_admin
    begin
      if current_user.admin == true
        return true
      end
    rescue
    end
    respond_to do |format|
      format.html do
        render file: "#{Rails.root}/public/404", layout: false, status: :forbidden
      end
      format.any  { head :forbidden }
    end
  end

  def create_issue
    auth_info = GithubInterface.authenticate(params[:code])
    params['access_token'] = auth_info['access_token']
    render '/home/create_issue'
  end

  def create_issue_anon
    params['access_token'] = ENV['GITHUB_SECRET_ANON']
    render '/home/create_issue'
  end

  def find_user
    @namespace = { action: params[:action], controller: params[:controller], id: params[:id] }
    @version = `(git describe --tags) 2>&1`
    @version = 'Development Version' if @version == '' || @version =~ /fatal:/
  end

  def options_req
    head(:ok)
  end

  def render_404
    respond_to do |format|
      format.html do
        render file: "#{Rails.root}/public/404", layout: false, status: :not_found
      end
      format.any  { head :not_found }
    end
  end

  def set_user
    # The API call came with an email and password
    if (params.key? :email) & (params.key? :password)
      login_email = params[:email].downcase
      @user = User.find_for_database_authentication(email: login_email)

      if @user and @user.valid_password?(params[:password])
        sign_in('user', @user)
      else
        respond_to do |format|
          format.json { render json: { msg: 'Email & Password do not match.' }, status: :unauthorized }
        end
      end

    elsif (params.key? :contribution_key) && (['jsonDataUpload', 'saveMedia'].include? params[:action]) &&
          (params[:type] == 'data_set')
      data_set = DataSet.find(params[:id])
      project = Project.find_by_id(data_set.project_id)
      key = project.contrib_keys.find_by_key(params[:contribution_key])
      if project && !key.nil? && data_set.key == key.name
        if params.key? :contributor_name
          owner = User.find_for_database_authentication(id: project.owner.id)
          sign_in('user', owner)
        else
          respond_to do |format|
            format.json { render json: { msg: 'Missing contributor name' }, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.json { render json: { msg: 'Contribution key not valid' }, status: :unauthorized }
        end
      end
    # The API call came with a contribution key and they are trying to access a project
    elsif (params.key? :contribution_key) && (['jsonDataUpload', 'saveMedia'].include? params[:action])
      project = Project.find_by_id(params[:id] || params[:pid])
      if project && !project.contrib_keys.find_by_key(params[:contribution_key].downcase).nil?
        if params.key? :contributor_name
          owner = User.find_for_database_authentication(id: project.owner.id)
          sign_in('user', owner)
        #           current_user = User.find_by_id(project.owner.id)
        else
          respond_to do |format|
            format.json { render json: { msg: 'Missing contributor name' }, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
          format.json { render json: { msg: 'Contribution key not valid' }, status: :unauthorized }
        end
      end

    # The API call came with a contribution key and they are trying to access a dataset
    elsif (params.key? :contribution_key) &&
          (['append', 'edit'].include? params[:action]) &&
          params[:controller].include?('data_sets')
      data_set = DataSet.find_by_id(params[:id])
      if data_set &&
        !data_set.project.contrib_keys.find_by_key(params[:contribution_key].downcase).nil? &&
        data_set.key == data_set.project.contrib_keys.where(key: params[:contribution_key].downcase)[0].name
        owner = User.find_for_database_authentication(id: data_set.owner.id)
        sign_in('user', owner)
        # current_user = User.find_by_id(data_set.owner.id)
      else
        respond_to do |format|
          format.json { render json: { msg: 'Contribution key not valid' }, status: :unauthorized }
        end
      end

    else
      respond_to do |format|
        format.json { render json: { msg: 'Must send Email & Password with this request' }, status: :unauthorized }
      end
    end
  end

  # Submission of issue to Github
  def submit_issue
    if params[:description] == ''
      redirect_to :back, flash: { error: 'Please fill out all required fields.' }
    else
      response = GithubInterface.send_issue(params)
      if response.code == '201'
        redirect_to root_path, flash: { success: 'Issue submitted successfully.' }
      else
        redirect_to root_path, flash: { error: JSON.parse(response.body)['message'] }
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, :remember_me, :bio, :admin) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :name, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password, :bio, :admin) }
  end
end

class UserError < RuntimeError
end

