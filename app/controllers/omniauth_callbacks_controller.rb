class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authorize

  def google_oauth2
    # Method 'from_omniauth' implemented in app/models/user.rb
    # takes the token provided by google and gets a user or creates one
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth']
      redirect_to new_user_session_path
    end
  end
end
