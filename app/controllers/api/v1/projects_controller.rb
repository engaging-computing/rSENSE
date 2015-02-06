module Api
  module V1
    class ProjectsController < ::ProjectsController
      skip_before_filter :authorize
      skip_before_filter :verify_authenticity_token
      before_filter :set_user, only: [:create]
      before_filter :allow_cross_site_requests

      def index
        super
      end

      def show
        super
      end

      def create
        project = Project.new
        project.user_id = @cur_user.id

        if params[:project_name].nil?
          if @cur_user.name[-1].downcase == 's'
            project.title = "#{@cur_user.name}' Project"
          else
            project.title = "#{@cur_user.name}'s Project"
          end
        else
          project.title = params[:project_name]
        end

        respond_to do |format|
          if project.save
            format.json { render json: project.to_hash(false), status: :created, location: project }
          else
            format.json { render json: project.errors, status: :unprocessable_entity }
          end
        end
      end

      def key
        project = Project.find_by_id(params[:id])
        key = project.contrib_keys.find_by_key(params[:contribution_key])
        if project.nil? || key.nil?
          respond_to do |format|
            format.json { render json: { error: 'Contribution key does not exist' }, status: 404 }
          end
        else
          respond_to do |format|
            format.json { render json: {}, status: :found }
          end
        end
      end
    end
  end
end

