module Api
  module V1
    class VisualizationsController < ActionController::VisualizationsController
      before_filter :allow_cross_site_requests
    end
  end
end
