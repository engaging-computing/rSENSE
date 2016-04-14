class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authorize

  def google_oauth2
      puts '\n\n\n\n\n\n\n\n\n\n\n'
      puts "123456dfknsdjlkfnadlksfnlkasndfasdkj"
      puts '\n\n\n\n\n\n\n\n\n\n\n\n\n'
      # Method 'from_omniauth' implemented in app/models/user.rb
      # takes the token provided by google and gets a user or creates one
      @user = User.from_omniauth(request.env["omniauth.auth"])

      puts "here"
      puts @user
      puts @user.persisted?

      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end
end
