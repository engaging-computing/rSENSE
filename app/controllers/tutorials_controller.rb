class TutorialsController < ApplicationController
  # GET /tutorials
  # GET /tutorials.json
  skip_before_filter :authorize, only: [:index]
  before_filter :authorize_admin, only: [:create, :update, :destroy]

  include ApplicationHelper
  include ActionView::Helpers::DateHelper

  def index
    @params = params

    @new_tutorial = Tutorial.new

    @getting_started = Tutorial.where(category: 'Getting Started')
    @working_with_data = Tutorial.where(category: 'Working With Data')
    @visualization = Tutorial.where(category: 'Visualizations')

    recur = params.key?(:recur) ? params[:recur].to_bool : false

    respond_to do |format|
      format.html
      format.json { render json: @tutorials.map { |t| t.to_hash(recur) } }
    end
  end

  # POST /tutorials
  # POST /tutorials.json
  def create
    @tutorial = Tutorial.new(tutorial_params)
    @tutorial.user_id = current_user.id

    respond_to do |format|
      if @tutorial.save
        format.html do
          redirect_to tutorials_url,
          notice: 'Tutorial was successfully created.'
        end
        format.json do
          render json: @tutorial.to_hash(false),
                 status: :created, location: @tutorial
        end
      else
        flash[:error] = @tutorial.errors.full_messages
        format.html { redirect_to tutorials_path }
        format.json do
          render json: @tutorial.errors,
                 status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @tutorial = Tutorial.find(params[:id])
  end

  def show
      redirect_to '/tutorials',
      notice: 'Tutorial was successfully updated.'
  end

  # PUT /tutorials/1
  # PUT /tutorials/1.json
  def update
    @tutorial = Tutorial.find(params[:id])
    update = tutorial_params

    respond_to do |format|
      if @tutorial.update_attributes(update)
        format.html do
          redirect_to @tutorial,
          notice: 'Tutorial was successfully updated.'
        end
        format.html { redirect_to tutorials_url }
        format.json { render json: {}, status: :ok }
      else
        format.html { render action: 'index' }
        format.json do
          render json: @tutorial.errors.full_messages,
                 status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /tutorials/1
  # DELETE /tutorials/1.json
  def destroy
    @tutorial = Tutorial.find(params[:id])

    @tutorial.media_objects.each(&:destroy)

    @tutorial.destroy

    respond_to do |format|
      format.html { redirect_to tutorials_url }
      format.json { render json: {}, status: :ok }
    end
  end

  private

  def tutorial_params
    params[:tutorial].permit(:content, :title, :user_id, :hidden, :youtube_url,
           :featured_media_id, :category)
  end
end
