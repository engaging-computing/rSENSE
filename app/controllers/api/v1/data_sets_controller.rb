module Api
  module V1
    class DataSetsController < ActionController::DataSetsController
      skip_before_filter :authorize
      skip_before_filter :authorize_allow_key
      before_filter :set_user, only: [:edit, :jsonDataUpload, :append]
      before_filter :allow_cross_site_requests

      def show
        super
      end

      def edit
        super
      end

      def jsonDataUpload
        super
      end

      def append
        dataset = DataSet.find_by_id(params[:id])

        unless dataset
          respond_to do |format|
            format.json { render json: {}, status: :not_found }
          end
          return false
        end

        if can_edit? dataset
          newdata = params[:data]
          DataSet.transaction do
            project = Project.find_by_id(dataset.project.id)
            uploader = FileUploader.new
            sane = uploader.sanitize_data(newdata)
            if sane[:status]
              newdata = uploader.swap_columns(sane[:data_obj], project)
              dataset.update_attributes(data: dataset.data.concat(newdata))

              respond_to do |format|
                format.json { render json: dataset, status: :ok }
              end
            else
              respond_to do |format|
                format.json { render json: { msg: sane[:msg] }, status: :unprocessable_entity }
              end
            end
          end
        else
          respond_to do |format|
            format.json { render json: {}, status: :unauthorized }
          end
        end
      end
    end
  end
end
