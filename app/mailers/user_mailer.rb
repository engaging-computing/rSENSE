require 'base64'

class UserMailer < ActionMailer::Base
  helper ActionView::Helpers::UrlHelper

  def validation_email(user)
    @user = user
    @url  = url_for(controller: 'users', action: 'validate', key: @user.validation_key, only_path: false)

    hostname = `hostname`.chomp
    from = "no-reply@#{hostname}"

    mail(from: from, to: user.email, subject: "Please verify your iSENSE account's email.")
  end

  def pw_reset_email(user)
    @user = user
    @url  = url_for(controller: 'users', action: 'pw_reset', key: @user.validation_key, only_path: false)

    hostname = `hostname`.chomp
    from = "no-reply@#{hostname}"

    mail(from: from, to: user.email, subject: 'Reset your iSENSE password.')
  end
end
