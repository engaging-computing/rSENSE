class PasswordsController < Devise::PasswordsController
  # I had to overide this function just so I could add the skip_before_filter.
  # This stops it from redirecting the user to sign in when they are trying to 
  # reset their password via the link from their forgot password email
  skip_before_filter :authorize, only: [:edit, :update]

  def create
    super
  end
  def new
    super
  end
  def update
    super
  end
  def edit
    super
  end
end