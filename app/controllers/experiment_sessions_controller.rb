class ExperimentSessionsController < ApplicationController
  # GET /experiment_sessions
  # GET /experiment_sessions.json
  def index
    @experiment_sessions = ExperimentSession.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @experiment_sessions }
    end
  end

  # GET /experiment_sessions/1
  # GET /experiment_sessions/1.json
  def show
    @experiment_session = ExperimentSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @experiment_session }
    end
  end

  # GET /experiment_sessions/new
  # GET /experiment_sessions/new.json
  def new
    @experiment_session = ExperimentSession.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @experiment_session }
    end
  end

  # GET /experiment_sessions/1/edit
  def edit
    @experiment_session = ExperimentSession.find(params[:id])
  end

  # POST /experiment_sessions
  # POST /experiment_sessions.json
  def create
    @experiment_session = ExperimentSession.new(params[:experiment_session])

    respond_to do |format|
      if @experiment_session.save
        format.html { redirect_to @experiment_session, notice: 'Experiment session was successfully created.' }
        format.json { render json: @experiment_session, status: :created, location: @experiment_session }
      else
        format.html { render action: "new" }
        format.json { render json: @experiment_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /experiment_sessions/1
  # PUT /experiment_sessions/1.json
  def update
    @experiment_session = ExperimentSession.find(params[:id])

    respond_to do |format|
      if @experiment_session.update_attributes(params[:experiment_session])
        format.html { redirect_to @experiment_session, notice: 'Experiment session was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @experiment_session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /experiment_sessions/1
  # DELETE /experiment_sessions/1.json
  def destroy
    @experiment_session = ExperimentSession.find(params[:id])
    @experiment_session.destroy

    respond_to do |format|
      format.html { redirect_to experiment_sessions_url }
      format.json { head :no_content }
    end
  end
end
