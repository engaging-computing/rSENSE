module Api
  module V1
    class FieldsController < ActionController::FieldsController
      skip_before_filter :authorize
      before_filter :set_user, only: [:create]

      def show
        super
      end

      def create
        super
      end
    end
  end
end
