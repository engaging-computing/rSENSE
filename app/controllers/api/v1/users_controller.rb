module Api
  module V1
    class UsersController < ::UsersController
      skip_before_filter :authorize
      skip_before_filter :verify_authenticity_token
      before_filter :set_user

      def my_info
        gravatar = Gravatar.new.url(current_user, 80)

        respond_to do |format|
          format.json { render json: { gravatar: gravatar, name: current_user.name }, status: :ok }
        end
      end
    end
  end
end
