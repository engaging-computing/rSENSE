module Api
  module V1
    class MediaObjectsController < ::MediaObjectsController
      skip_before_filter :authorize
      skip_before_filter :verify_authenticity_token
      before_filter :set_user, only: [:saveMedia]

      def show
        super
      end

      def saveMedia
        # Figure out where we are uploading data to
        @errors = nil
        type = params['type']
        id = params['id']

        # Set up the file for upload
        file_type = params[:upload].content_type.split('/')[0]
        file_path = params[:upload].tempfile
        file_name = params[:upload].original_filename

        # Rotate based on EXIF data, then strip it out.
        unless file_type == 'image'
          respond_to do |format|
            format.json { render json: { error: 'API only supports images', msg: 'API only supports images' }, status: :unprocessable_entity }
          end
          return
        end

        # Check for rotation.
        fix_rot = MiniMagick::Image.read(file_path)
        fix_rot.auto_orient
        file_path = '/tmp/' + SecureRandom.hex
        File.open(file_path, 'wb') do |ff|
          fix_rot.write ff
        end

        @mo = MediaObject.new
        @mo.name = file_name
        @mo.file = file_name
        @mo.media_type = file_type

        # Build media object params based on what we are doing
        case type
        when 'project'
          @project = Project.find_by_id(id) || nil
          if can_edit?(@project) && !@project.nil?
            @mo.user_id = @project.owner.id
            @mo.project_id = @project.id
          else
            @errors = 'Either you do not have access to this project, or it does not exist.'
          end
        when 'data_set'
          @data_set = DataSet.find_by_id(id) || nil
          if can_edit?(@data_set) && !@data_set.nil?
            @mo.user_id = @data_set.owner.id
            @mo.data_set_id = @data_set.id
            @mo.project_id = @data_set.project_id
          else
            @errors = 'Either you do not have access to this data set, or it does not exist.'
          end
        else
          @errors = "#{type} is not a correct type."
        end

        # If we managed to make some params build the media object
        if !@mo.user_id.nil? || @errors.nil?
          # Save the file
          @mo.check_store!

          FileUtils.cp(file_path, @mo.file_name)
          File.chmod(0644, @mo.file_name)

          @mo.add_tn

          # Generate a media object with the calculated params
          respond_to do |format|
            if @mo.save
              format.json { render json: @mo.to_hash(false), status: :ok }
            else
              format.json { render json: { error: @mo.errors.full_messages, msg: @mo.errors.full_messages }, status: :unprocessable_entity }
            end
          end
        else
          # Tell the user there is a problem with uploading their image.
          respond_to do |format|
            format.json { render json: { error: @errors, msg: @errors }, status: :unprocessable_entity }
          end
        end
      end
    end
  end
end
