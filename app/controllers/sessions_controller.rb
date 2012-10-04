class SessionsController < ApplicationController
  skip_before_filter :authorize, only: ['create','new'] 
    
  def new
  end

  def create
      user = User.find_by_email(params[:username_or_email])
      if !user
        user = User.find_by_username(params[:username_or_email])
      end
      
      if user and user.authenticate(params[:password])
          session[:user_id] = user.id
          
          
          redirect_to(request.env["HTTP_REFERER"] || users_url)
      else
        redirect_to login_url, alert: "Invalid username/password combination"
      end
      
      
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url, notice: "Logged out"
  end
end
