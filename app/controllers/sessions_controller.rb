class SessionsController < ApplicationController
  skip_before_filter :authorize, only: ['create', 'new', 'verify']

  protect_from_forgery except: :create

  # GET /sessions/new
  def new
    if request.referrer && !(URI(request.referrer).path == login_path)
      if request.referrer.include? '/users'
        session[:redirect_to] = '/home/index'
      else
        session[:redirect_to] = request.referrer
      end
    else
      session[:redirect_to] = '/home/index'
    end
  end

  def create
    session[:key] = nil
    session[:contrib_access] = nil
    login_email = params[:email].downcase

    @user = User.where('lower(email) = ?', login_email).first

    if @user and @user.authenticate(params[:password])
      session[:user_id] = @user.id
      @user.update_attributes(last_login: Time.now)

      respond_to do |format|
        format.html { redirect_to session[:redirect_to] }
        format.json { render json: { authenticity_token: form_authenticity_token, user: @user.to_hash(false) }, status: :ok }
      end
    else
      flash.now[:error] = 'The entered email and password do not match'
      flash.now[:email] = params[:email]
      respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: {}, status: :unauthorized }
      end
    end
  end

  # GET /auth/github
  def github_authorize
    base_url = 'https://github.com/login/oauth/authorize'

    client_id = ENV['GITHUB_ID']
    redirect_uri = 'http://rsense-dev.cs.uml.edu/auth/github/callback'
    scope = 'repo'
    state = current_state

    auth_url = base_url + '?client_id=' + client_id
    auth_url += '&redirect_uri=' + redirect_uri
    auth_url += '&scope=' + scope
    auth_url += '&state=' + state

    redirect_to auth_url
  end

  def destroy
    session[:user_id] = nil
    session[:key] = nil
    session[:contrib_access] = nil
    session[:state] = nil
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Logged out' }
      format.json { render json: {}, status: :ok }
    end
  end

  # GET /sessions/verify
  def verify
    respond_to do |format|
      permission = true
      unless params[:project_id].nil? || params[:verify_owner].nil?
        owner_id = Project.find(params[:project_id]).user_id
        verify = params[:verify_owner] == 'true'
        session_destroyed = session[:user_id].nil?
        is_admin = (!session_destroyed and User.find(session[:user_id]).admin)
        permission = (verify && owner_id == session[:user_id]) || !verify || is_admin
      end

      if session[:user_id].nil? || !permission
        format.json { render json: '{}', status: :unauthorized }
      else
        format.json { render json: '{}', status: :ok }
      end
    end
  end

  private

  def current_state
    if session[:state]
      session[:state]
    elsif session[:state] = SecureRandom.hex
      session[:state]
    end
  end
end
