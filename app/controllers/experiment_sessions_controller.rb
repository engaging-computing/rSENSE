class ExperimentSessionsController < ApplicationController
  # GET /experiment_sessions
  # GET /experiment_sessions.json
  skip_before_filter :authorize, only: [:show,:index]
  
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
    @DataSet = DataSet.find(:session_id => @experiment_session.id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @experiment_session }
    end
  end

  # GET /experiment_sessions/1/edit
  def edit
    @experiment_session = ExperimentSession.find(params[:id])
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
  
  def manualUpload
    
    @experiment_session = ExperimentSession.find(params[:id])
                                                 
    header = params[:header]
    rows = params[:data]
    data = Array.new
        
    rows.each_with_index do |datapoints, r|
      data[r] = Hash.new
      datapoints.each_with_index do |dp, i|
        if i > 0 #ignore numbered row at top of ajax
          data[r] = Hash.new
          dp.each_with_index do |d, j|
            data[r][header[j]] = d
          end
        end
      end
    end

    old_data = DataSet.all({:experiment_session_id => @experiment_session.id})

    unless old_data.nil?
      old_data.each do |od|
        od.destroy
      end
    end
    
    data_to_add = DataSet.new(:experiment_session_id => @experiment_session.id, :data => data)    
    
    if data_to_add.save!
      response = { status: 'success', message: data }
    else
      response = { status: 'fail' }
    end
    
    respond_to do |format|
      format.json { render json: response }
    end
    
  end
end
