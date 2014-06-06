module Api
  module V1
    class UsersController < ActionController::UsersController
      skip_before_filter :authorize
      skip_before_filter :verify_authenticity_token
      before_filter :set_user
      before_filter :allow_cross_site_requests

      def my_info
        gravatar = Gravatar.new.url(@cur_user, 80)

        respond_to do |format|
          format.json { render json: { gravatar: gravatar, name: @cur_user.name }, status: :ok }
        end
      end
    end
  end
end
