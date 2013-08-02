class SessionsController < ApplicationController
  skip_before_filter :authorize, only: ['create','new'] 
  
  protect_from_forgery :except => :create
  
  def create
    login_name = params[:username_or_email]
      
      user = User.find(:first, :conditions => [ "lower(email) = ?", login_name.downcase ])
      
      if !user
        user = User.find(:first, :conditions => [ "lower(username) = ?", login_name.downcase ])
      end
      
      if user and user.authenticate(params[:password])
      
        session[:user_id] = user.id
        response = { status: 'success', authenticity_token: form_authenticity_token }
          
      else

        response = { status: 'fail' }

      end
      
      respond_to do |format|
        format.json { render json: response }
      end
      
      
  end

  def destroy
    session[:user_id] = nil
    respond_to do |format| 
      format.html { redirect_to :back, notice: "Logged out" }
      format.json { render json: {}, status: :ok }
    end
  end
end
