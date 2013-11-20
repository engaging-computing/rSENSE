class SessionsController < ApplicationController
  skip_before_filter :authorize, only: ['create','new','verify'] 
  
  protect_from_forgery :except => :create
  
  #GET /sessions/new
  def new
    if request.referrer
      if request.fullpath == login_path
        session[:redirect_to] = "/home/index"
      else
        session[:redirect_to] = request.referrer
      end
    else
      session[:redirect_to] = "/home/index"
    end
  end
  
  def create
    
    login_name = params[:username_or_email].downcase
    
    @user = User.where("lower(email) = ?", login_name).first
      
    if !@user
      @user = User.where("lower(username) = ?", login_name).first
    end
    
    if @user and @user.authenticate(params[:password])
      session[:user_id] = @user.id
      @user.update_attributes(:last_login => Time.now())

      respond_to do |format|
        format.html { redirect_to session[:redirect_to]}
        format.json { render json: {authenticity_token: form_authenticity_token}, status: :ok }
      end
    else
      flash.now[:error] = "The entered username/email and password do not match"
      flash.now[:username_or_email] = params[:username_or_email]
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: {}, status: :unauthorized }
      end
    end
  end

  def destroy
    session[:user_id] = nil
    respond_to do |format| 
      format.html { redirect_to :back, notice: "Logged out" }
      format.json { render json: {}, status: :ok }
    end
  end

  # GET /sessions/verify
  def verify
    respond_to do |format|
      if session[:user_id] == nil
        format.json {render json: "{}", status: :unauthorized}
      else
        format.json {render json: "{}", status: :ok}
      end
    end
  end
end
