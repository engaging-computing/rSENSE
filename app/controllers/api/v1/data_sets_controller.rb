module Api
  module V1
    class DataSetsController < ActionController::DataSetsController
      skip_before_filter :authorize
      skip_before_filter :authorize_allow_key
      before_filter :set_user, only: [:edit, :jsonDataUpload]

      def show
        super
      end

      def edit
        super
      end

      def jsonDataUpload
        super
      end
    end
  end
end
