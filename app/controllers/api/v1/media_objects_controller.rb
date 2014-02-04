module Api
  module V1
    class MediaObjectsController < ActionController::MediaObjectsController
      skip_before_filter :authorize
      before_filter :set_user, :only => [:saveMedia]

      def show
        super
      end
      
      def saveMedia
        super
      end

    end
  end
end