require 'base64'

class UserMailer < ActionMailer::Base
  helper ActionView::Helpers::UrlHelper
  
  def validation_email(user)
    @user = user

    from = "no-reply@#{url_for(controller: "home", action: "index", only_path: false, port: nil).split('/')[2].sub('www.', '')}"
    
    @url = url_for controller: 'users', action: 'validate', key: Base64.encode64(@user.validation_key), only_path: false
    
    mail(from: from, to: user.email, subject: "Please verify your iSENSE account's email.")
  end
end
