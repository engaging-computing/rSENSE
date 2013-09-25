class SessionsController < ApplicationController
  skip_before_filter :authorize, only: ['create','new','verify'] 
  
  protect_from_forgery :except => :create
  
  def create
    login_name = params[:username_or_email]
      
    user = User.find(:first, :conditions => [ "lower(email) = ?", login_name.downcase ])
      
    if !user
      user = User.find(:first, :conditions => [ "lower(username) = ?", login_name.downcase ])
    end
  
    status = :ok

    if user and user.authenticate(params[:password])  
      good = true
      session[:user_id] = user.id
      response = { status: 'success', authenticity_token: form_authenticity_token }    
    else
      status = 403
      response = { status: 'fail' }
    end
      
    respond_to do |format|
      format.json { render json: response, status: status }
      format.html { render text: response.to_json, status: status }
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
