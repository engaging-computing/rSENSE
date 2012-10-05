class SessionsController < ApplicationController
  skip_before_filter :authorize, only: ['create','new'] 
    
  def new
  end

  def create
    login_name = params[:username_or_email]
      user = User.find_by_email(login_name.downcase)
      if !user
        user = User.find_by_username(login_name)
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
