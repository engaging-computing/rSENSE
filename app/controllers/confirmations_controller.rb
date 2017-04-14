class ConfirmationsController < Devise::ConfirmationsController
  skip_before_filter :authorize, only: [:show, :create, :new]
end