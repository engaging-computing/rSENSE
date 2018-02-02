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
    user.send_reset_password_instructions
  end

  def report_content_email(params)
    hostname = `hostname`.chomp
    from = "admin@#{hostname}"

    @current_user = params[:current_user]
    @location = params[:location]
    @content = params[:content]

    mail(from: from, to: 'admin@isenseproject.org', cc: 'joelsavitz@gmail.com', subject: 'Report of inappropriate content on iSense.')
  end
end
