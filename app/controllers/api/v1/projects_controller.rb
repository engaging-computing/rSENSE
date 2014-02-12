module Api
  module V1
    class ProjectsController < ActionController::ProjectsController
      skip_before_filter :authorize
      before_filter :set_user, :only => [:create]

      def index
        super
      end

      def show
        super
      end
      
      def create
        super
      end
      
    end
  end
end

  
  
 