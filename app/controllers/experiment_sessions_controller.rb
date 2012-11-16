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
  
  def postCSV
    
    logger.info "WIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLESWIGGLES"
    
    logger.info params
    logger.info file
    respond_to do |format|
    
      format.json render json: {data: "Derp"}
    
    end
    
  end
  
  def getData
    
=begin
    testObject = {metadata:[
    	{name: "name", label: "NAME", datatype: "string", editable: true}
    ],

    data:[
    	{id:1, values: {name: "Duke"}}
    ]}
=end

    require "CSV"
    
    data = CSV.read(Rails.application.assets['testdata.csv'].pathname)
    
    headers = data[0]
    data = data[1..(data.size-1)]
    
    testObject = {}
    
    testObject["metadata"] = []
    testObject["data"] = []

    headers.count.times do |i|
      testObject["metadata"].push({name: headers[i], label: headers[i], datatype: "string", editable: true})
    end

    data.count.times do |i|
      
      values = {}
      
      data[i].count.times do |j|
        
        values[headers[j]] = 
          if(data[i][j] != nil)
             data[i][j]
          else
             ""
          end
        
      end
      
      testObject["data"].push({id: i, values: values})

    end


    respond_to do |format|
      format.json { render json: testObject }
    end
    
  end
  
end
