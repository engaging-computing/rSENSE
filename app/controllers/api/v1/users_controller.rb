module Api
  module V1
    class UsersController < ActionController::UsersController
      skip_before_filter :authorize
      before_filter :set_user

      def my_info
        gravatar = Gravatar.new.url(@cur_user, 80)

        respond_to do |format|
          format.json { render json: { gravatar: gravatar, username: @cur_user.name }, status: :ok }
        end
      end
    end
  end
end
