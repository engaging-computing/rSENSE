module Api
  module V1
    class ProjectsController < ::ProjectsController
      skip_before_filter :authorize
      skip_before_filter :verify_authenticity_token
      before_filter :set_user, only: [:create, :add_key]

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
        if params[:id].nil? || params[:contribution_key].nil?
          respond_to do |format|
            format.json { render json: { error: 'Neither Project ID nor Contribution Key can be empty.' }, status: :unprocessable_entity }
          end
          return
        end

        project = Project.find_by_id(params[:id])

        respond_to do |format|
          if project.nil?
            format.json { render json: { error: 'Project not found.' }, status: 404 }
          else
            key = project.contrib_keys.find_by_key(params[:contribution_key])
          end

          if key.nil?
            format.json { render json: { error: 'Contribution key does not exist.' }, status: 404 }
          else
            format.json { render json: { contribution_key: params[:contribution_key] }, status: :found }
          end
        end
      end

      def add_key
        if params[:contrib_key].nil?
          respond_to do |format|
            format.json { render json: { msg: 'contrib_key is nil' }, status: :unprocessable_entity }
          end
          return
        end

        if params[:contrib_key][:name].nil?
          respond_to do |format|
            format.json { render json: { msg: 'name is nil' }, status: :unprocessable_entity }
          end
          return
        end

        if params[:contrib_key][:key].nil?
          respond_to do |format|
            format.json { render json: { msg: 'key is nil' }, status: :unprocessable_entity }
          end
          return
        end

        @project = Project.find(params[:id])

        unless @cur_user.id == @project.user_id
          respond_to do |format|
            format.json { render json: { msg: 'User does not own the project.' }, status: :unauthorized }
          end
          return
        end

        key = @project.contrib_keys.find_by_key(params[:contrib_key][:key])
        unless key.nil?
          respond_to do |format|
            format.json { render json: { msg: 'key already exists.' }, status: :conflict }
          end
          return
        end

        key = ContribKey.new(name: params[:contrib_key][:name], project_id: @project.id, key: params[:contrib_key][:key])
        respond_to do |format|
          if key.save
            format.json { render json: { msg: 'Success' }, status: :created }
          else
            format.json { render json: { msg: 'Unprocessable Entity.' }, status: :unprocessable_entity }
          end
        end
      end
    end
  end
end
