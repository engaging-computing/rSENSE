class RegistrationsController < Devise::RegistrationsController
  prepend_before_action :check_captcha, only: [:create]

  skip_before_filter :authorize, only: [:new, :create]

  private

  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_up_params
      flash[:recaptcha_error] = 'Verification failed. Please click the reCAPTCHA checkbox below.'
      respond_with(resource, location: new_user_registration_path)
    end
  end
end
