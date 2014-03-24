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

  def destroy
    session[:user_id] = nil
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Logged out' }
      format.json { render json: {}, status: :ok }
    end
  end

  # GET /sessions/verify
  def verify
    respond_to do |format|
      if session[:user_id].nil?
        format.json { render json: '{}', status: :unauthorized }
      else
        format.json { render json: '{}', status: :ok }
      end
    end
  end
end
