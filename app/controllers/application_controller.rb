class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :find_user
  before_filter :authorize

  skip_before_filter :verify_authenticity_token, only: [:options_req]
  skip_before_filter :find_user, only: [:options_req]
  skip_before_filter :authorize, only: [:options_req]

  def allow_cross_site_requests
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def authorize
    unless User.find_by_id(session[:user_id])
      redirect_to '/login'
    end
  end

  def authorize_allow_key
    return if User.find_by_id(session[:user_id])

    ckey = session[:contrib_access].to_i

    proj = Project.find_by_id(params[:id] || params[:pid] || params[:data_set][:project_id])
    return if proj && proj.id == ckey

    dset = DataSet.find_by_id(params[:id])
    return if dset && ckey == dset.project.id

    redirect_to '/login'
  end

  def authorize_admin
    begin
      if @cur_user.admin == true
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
    auth_info = github_authenticate
    params['access_token'] = auth_info['access_token']
    render '/home/create_issue'
  end

  def create_issue_anon
    params['access_token'] = ENV['GITHUB_SECRET_ANON']
    render '/home/create_issue'
  end

  def find_user
    @cur_user = User.find_by_id(session[:user_id])
    @namespace = { action: params[:action], controller: params[:controller] }
    @version = `(git describe --tags) 2>&1`
    @version = 'Development Version' if @version == '' || @version =~ /fatal:/
  end

  def github_authenticate
    new_params = {}
    # IMPORTANT #
    # These variables need to be set on the machine that is running the server
    new_params[:client_id] = ENV['GITHUB_ID']
    new_params[:client_secret] = ENV['GITHUB_SECRET']
    new_params[:code] = params[:code]

    url = URI.parse('https://github.com/login/oauth/access_token')

    req = Net::HTTP::Post.new(url.request_uri)
    req.set_form_data(new_params)
    req['accept'] = 'application/json'
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')

    response = http.request(req)

    JSON.parse(response.body)
  end

  def options_req
    allow_cross_site_requests
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

      @user = User.where('lower(email) = ?', login_email).first

      if @user and @user.authenticate(params[:password])
        @user.update_attributes(last_login: Time.now)
        @cur_user = @user
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
          @cur_user = User.find_by_id(project.owner.id)
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
          @cur_user = User.find_by_id(project.owner.id)
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
          data_set.key == params[:contribution_key].downcase &&
          !data_set.project.contrib_keys.find_by_key(params[:contribution_key].downcase).nil?
        @cur_user = User.find_by_id(data_set.owner.id)
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

  def submit_issue
    if params[:logged_in] == '1'
      logged_in = 'Y'
    elsif params[:logged_in] == '0'
      logged_in = 'N'
    else
      logged_in = 'N/A'
    end

    if params[:is_admin] == '1'
      admin = 'Y'
    elsif params[:is_admin] == '0'
      admin = 'N'
    else
      admin = 'N/A'
    end

    if params[:description] == ''
      redirect_to :back
      flash[:error] = 'Please fill out all required fields.'
    else
      b =  "**General description:** #{params[:description]}\n\n"\
           "**live/dev/localhost:** live\n"\
           "**iSENSE Version:** #{params[:isense_version]}\n"\
           "**Logged in (Y or N):** #{logged_in}\n"\
           "**Admin (Y or N):** #{admin}\n\n"\
           "**OS:** #{params[:os]}\n"\
           "**Browser/Version:** #{params[:browser]}\n\n"\
           "**Steps to Reproduce:** #{params[:instructions]}\n\n"\
           "#{params[:user_id]}"

      new_params = {}
      new_params['title'] = 'User Submitted Issue'
      new_params['body'] = b

      base_url = 'https://api.github.com/repos/isenseDev/rSENSE/issues'
      token = '?access_token=' + params[:access_token]
      url = URI.parse(base_url + token)

      req = Net::HTTP::Post.new(url.request_uri)
      req.body = new_params.to_json
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.scheme == 'https')
      response = http.request(req)

      if response.code == '201'
        redirect_to root_path, flash: { success: 'Issue submitted successfully.' }
      else
        redirect_to root_path, flash: { error: JSON.parse(response.body)['message'] }
      end
    end
  end
end

class UserError < RuntimeError
end
