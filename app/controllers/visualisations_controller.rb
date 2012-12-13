class VisualisationsController < ApplicationController
  skip_before_filter :authorize, only: [:show, :displayVis, :index]
  
  # GET /visualisations
  # GET /visualisations.json
  def index
    @visualisations = Visualisation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @visualisations }
    end
  end

  # GET /visualisations/1
  # GET /visualisations/1.json
  def show
    @visualisation = Visualisation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @visualisation }
    end
  end

  # GET /visualisations/new
  # GET /visualisations/new.json
  def new
    @visualisation = Visualisation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @visualisation }
    end
  end

  # GET /visualisations/1/edit
  def edit
    @visualisation = Visualisation.find(params[:id])
  end

  # POST /visualisations
  # POST /visualisations.json
  def create
    @visualisation = Visualisation.new(params[:visualisation])

    respond_to do |format|
      if @visualisation.save
        format.html { redirect_to @visualisation, notice: 'Visualisation was successfully created.' }
        format.json { render json: @visualisation, status: :created, location: @visualisation }
      else
        format.html { render action: "new" }
        format.json { render json: @visualisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /visualisations/1
  # PUT /visualisations/1.json
  def update
    @visualisation = Visualisation.find(params[:id])

    respond_to do |format|
      if @visualisation.update_attributes(params[:visualisation])
        format.html { redirect_to @visualisation, notice: 'Visualisation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @visualisation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /visualisations/1
  # DELETE /visualisations/1.json
  def destroy
    @visualisation = Visualisation.find(params[:id])
    @visualisation.destroy

    respond_to do |format|
      format.html { redirect_to visualisations_url }
      format.json { head :no_content }
    end
  end
  
  def displayVis
    
    @experiment = Experiment.find_by_id params[:id]
    
    @sessions = []
    format_fields = []
    format_data = []
    metadata = {}
    
    if( !params[:sessions].nil? )
      seses = params[:sessions].split(",")
      seses.each do |s|
        begin
          @sessions.push ExperimentSession.find_by_id_and_experiment_id s, params[:id]
        rescue
          logger.info "Either experiment id or session does not exist in the DB"
        end   
      end
    else
      @sessions = ExperimentSession.find_all_by_experiment_id params[:id]
    end
    
    #Get MONGO DATAZ
    
    @sessions.each do |session|
      d = DataSet.find_by_experiment_session_id(session.id)
      session[:data] = d.data
    end

    format_fields.push({ typeID: -1, unitName: "String", fieldID: -1, fieldName: "Session Name (id)" })
    
    @experiment.fields.each do |field|
      format_fields.push({ typeID: field.field_type, unitName: field.unit, fieldID: field.id, fieldName: field.name })
    end
    
    @sessions.each do |session|
      session.data.each do |rows|
        metadata["#{session.title}(#{session.id})"] = { name: session.title, user_id: session.user_id, session_id: session.id, timecreated: session.created_at, timemodified: session.updated_at }
        arr = []
        arr.push "#{session.title}(#{session.id})"
        rows.each do |dp|
          key = dp.keys
          arr.push dp[key[0]]
        end
        format_data.push arr
      end
    end
       

    @Data = { experimentName: @experiment.title, experimentID: @experiment.id, hasPics: false, fields: format_fields, dataPoints: format_data, metadata: metadata }
    
    
    respond_to do |format|
      format.html
    end
  end
  
end
