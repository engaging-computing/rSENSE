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
        puts "\n\n\nThis is from api project controller key #{params}\n\n\n" #server log
        #TODO add new key
        puts "AAA #{params}" #server log

        @project = Project.find(params[:contrib_key=>:project_id])

        if @cur_user.id == @project.user_id
          #add new key to project
          puts "\n\n\n OWNER \n\n\n" #server log
          session[:name] = params[:key_name]
          session[:key] = params[:key]
          session[:project_id] = @project.id
          
          #puts "\n\n\nAAABBB #{contrib_key_params}\n\n\n" #server log
          @key = ContribKey.new(:contrib_key)
          @key.save
          format.json { render json: project.errors, status: :ok }
        else
          puts "\n\n\n Not owner \n\n\n" #server log
          format.json { render json: project.errors, status: :authorize }
        end
      end
      
      def contrib_key_params
        params.require(:key).permit(:name, :key, :project_id)
      end
    end
  end
end

