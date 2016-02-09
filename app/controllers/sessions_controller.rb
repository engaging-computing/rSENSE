class SessionsController < ApplicationController
  skip_before_filter :authorize, only: ['permissions']

  protect_from_forgery except: :create

  def github_authorize
    base_url = 'https://github.com/login/oauth/authorize'

    client_id = ENV['GITHUB_ID']

    redirect_uri = 'http://isenseproject.org/auth/github/callback'
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

  # GET /sessions/permissions
  def permissions
    @permiss = []
    # Session is null
    unless user_signed_in?
      respond_to do |format|
        format.js {}
        format.json { head :unauthorized }
      end
      return
    end

    is_admin = current_user.admin
    @permiss.push 'save'

    # Not admin, and you don't own or didn't specify a project
    unless is_admin
      if params[:project_id].nil? or
         Project.find(params[:project_id]).user_id != current_user.id
        respond_to do |format|
          format.json { render json: { permissions: @permiss }, status: :ok }
          format.js {}
        end
        return
      end
    end

    # You're the admin or you own the project (or both)
    @permiss.push 'project'
    respond_to do |format|
      format.json { render json: { permissions: @permiss }, status: :ok }
      format.js {}
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
