class ExperimentsController < ApplicationController  
  # GET /experiments
  # GET /experiments.json
  skip_before_filter :authorize, only: [:show,:index]  
    
  def index

    if !params[:sort].nil?
        sort = params[:sort]
    else
        sort = "DESC"
    end
    
    @featured_3 = Experiment.where(featured: true).order("updated_at DESC").limit(3);
    
    @experiments = Experiment.filter(params[:filters]).search(params[:search]).paginate(page: params[:page], per_page: 8).order("created_at #{sort}")
    
  end

  # GET /experiments/1
  # GET /experiments/1.json
  def show
    @experiment = Experiment.find(params[:id])
		
		#Determine if the experiment is cloned
		@cloned_experiment = nil
    if(!@experiment.cloned_from.nil?)
			@cloned_experiment = Experiment.find(@experiment.cloned_from)
		end
		
		#Get number of likes
		@likes = @experiment.likes.count
		
		@liked_by_cur_user = false
		if(Like.find_by_user_id_and_experiment_id(@cur_user,@experiment.id)) 
			@liked_by_cur_user = true
		end
	
		
		respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @experiment }
    end
  end
  
  def createSession
    
    @experiment = Experiment.find(params[:id])
   
  end

  # GET /experiments/new
  # GET /experiments/new.json
  def new
    @experiment = Experiment.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @experiment }
    end
  end

  # GET /experiments/1/edit
  def edit
    @experiment = Experiment.find(params[:id])
  end

  # POST /experiments
  # POST /experiments.json
  def create
    #@experiment = Experiment.new(params[:experiment])
		
		if(params[:experiment_id])
			@tmp_exp = Experiment.find(params[:experiment_id])
			@experiment = Experiment.new({user_id: @cur_user.id, title:"#{@tmp_exp.title} (clone)", content: @tmp_exp.content, filter: @tmp_exp.filter, cloned_from:@tmp_exp.id})
			success = @experiment.save
			@tmp_exp.fields.all.each do |f|
				Field.create({experiment_id:@experiment.id, field_type: f.field_type, name: f.name, unit: f.unit})
			end
		else
			@experiment = Experiment.new({user_id: @cur_user.id, title:"#{@cur_user.firstname} #{@cur_user.lastname[0].pluralize} Experiment"})
			success = @experiment.save
		end

		respond_to do |format|
      if success
        format.html { redirect_to @experiment, notice: 'Experiment was successfully created.' }
        format.json { render json: @experiment, status: :created, location: @experiment }
      else
        format.html { render action: "new" }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /experiments/1s
  # PUT /experiments/1.json
  def update
    @experiment = Experiment.find(params[:id])

    respond_to do |format|
      if @experiment.update_attributes(params[:experiment])
        format.html { redirect_to @experiment, notice: 'Experiment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @experiment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /experiments/1
  # DELETE /experiments/1.json
  def destroy
    @experiment = Experiment.find(params[:id])
    @experiment.destroy

    respond_to do |format|
      format.html { redirect_to experiments_url }
      format.json { head :no_content }
    end
  end
  
  def addExperimentSession
    @experiment = Experiment.find(params[:id])
    #@experiment_session = ExperimentSession.new(:user_id => @cur_user.id, :experiment_id => @experiment.id, :title => "#{@cur_user.name}'s Session")

    header = params[:ses_info][:header]
    data = params[:ses_info][:data]

    if !data.nil?

      mongo_data = []
      row = []
      
      data.each do |dp|
        header.each do |h|
          id = h[1]["id"]
          row << { id => dp }
        end
        mongo_data << row
      end
      
      response = data
    else
      response = ["No data"]
    end

    respond_to do |format|
      format.html { render json: response }
      format.json { render json: response }
    end    
  end
	
	def updateLikedStatus
		
		like = Like.find_by_user_id_and_experiment_id(@cur_user,params[:id])
	
		if(like)
			Like.destroy(like.id)
		else
			Like.create({user_id:@cur_user.id,experiment_id:params[:id]})
		end
    
		count = Experiment.find(params[:id]).likes.count
		
		if(count == 0 || count > 1)
			@response = count.to_s + " people liked this"
		else
			@response = count.to_s + " person liked this"
		end
		
		respond_to do |format|
      format.json { render json: {update: @response} }
    end
	end
	
	
	def manualEntry
		@experiment = Experiment.find(params[:id])
		logger.info "============================================================================="
	end
	
  ## POST /experiment_sessions/1
  def postCSV

=begin
    #Grab the experiment so we can get field names
    @experiment = Experiment.find(params[:id])
    
    #Get a link to the temp file uploaded to the server
    @file = params[:csv]
    
    #Read the CSV
    require "csv"
    
    data = CSV.read(@file.tempfile)
    
    data = sortColumns(data, doColumnsMatch(@experiment, data[0]))
    
    #Parse out the headers and the data
    headers = data[0]
    data = data[1..(data.size-1)]
    
    #Data that will be stuffed into mongo
    mongo_data = Array.new
    
    #Build the object that will be displayed in the table
    @dataObject = {}
    @dataObject["metadata"] = []
    @dataObject["data"] = []

    headers.count.times do |i|
      @dataObject["metadata"].push({name: headers[i], label: headers[i], datatype: "string", editable: true})
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
      @dataObject["data"].push({id: i, values: values})
    end
  
    @dataObject["data"].each do |d|
      mongo_data.push d.values
    end
      
    data_to_add = DataSet.new(:experiment_session_id => @experiment_session.id, :data => mongo_data)    
    
    if data_to_add.save!
      response = { status: 'success', message: @dataObject }
    else
      response = { status: 'fail' }
    end  
      
    #Send the object as json
    respond_to do |format|
      format.json { render json: response }
    end
    
=end
    
  end
  
end
