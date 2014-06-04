module Api
  module V1
    class FieldsController < ActionController::FieldsController
      skip_before_filter :authorize
      before_filter :set_user, only: [:create]
      before_filter :allow_cross_site_requests

      def show
        super
      end

      def create
        super
      end
    end
  end
end
