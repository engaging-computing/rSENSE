module Api
  module V1
    class ProjectsController < ::ProjectsController
      skip_before_filter :authorize
      skip_before_filter :verify_authenticity_token
      before_filter :set_user, only: [:create, :key]
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
        @project = Project.find(params[:contrib_key][:project_id])

        if @cur_user.id == @project.user_id
          session[:name] = params[:key_name]
          session[:key] = params[:key]
          session[:project_id] = @project.id
          key = ContribKey.new(contrib_key_params)
          key.save
        else
          errors = "User does not own the project."
        end

        respond_to do |format|
          if key != nil
            format.json { render json: { msg: "Success"}, status: :created }
          elsif @cur_user.id != @project.user_id
            format.json { render json: { msg: errors }, status: :unauthorized }
          else
            @errors = "Unprocessable Entity."
            format.json { render json: { error: errors }, status: :unprocessable_entity }
          end
        end
      end

      def contrib_key_params
        params.require(:contrib_key).permit(:name, :project_id, :key)
      end
    end
  end
end