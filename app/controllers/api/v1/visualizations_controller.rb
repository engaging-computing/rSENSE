module Api
  module V1
    class VisualizationsController < ::VisualizationsController
      before_filter :allow_cross_site_requests
      skip_before_filter :verify_authenticity_token
    end
  end
end
