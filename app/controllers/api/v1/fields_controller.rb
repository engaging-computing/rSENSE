module Api
  module V1
    class FieldsController < ::FieldsController
      skip_before_filter :authorize
      skip_before_filter :verify_authenticity_token
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
