module Api
  module V1
    class VisualizationsController < ::VisualizationsController
      skip_before_filter :verify_authenticity_token
    end
  end
end
