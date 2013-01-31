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
    @data_set = DataSet.find_by_experiment_session_id(@experiment_session.id)
    
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
  
  def manualEntry
      @experiment = Experiment.find(params[:eid])
  end
  
  # POST /experiment_session/1/manualUpload
  def manualUpload
    
    @experiment = Experiment.find(params[:eid])

    header = params[:ses_info][:header]
    data = params[:ses_info][:data]

    if !data.nil?
     
      @experiment_session = ExperimentSession.create(:user_id => @cur_user.id, :experiment_id => @experiment.id, :title => "#{@cur_user.name}'s Session")

      mongo_data = []
      
      data.each do |dp|
        row = []
        header.each_with_index do |field, col_index|
          row << { field[1][:id] => dp[1][col_index] }
        end
        mongo_data << row
      end
                
      data_to_add = DataSet.new(:experiment_session_id => @experiment_session.id, :data => mongo_data)    
      
      followURL = url_for :controller => :visualizations, :action => :displayVis, :id => @experiment.id, :sessions => "#{@experiment_session.id}"
      
      if data_to_add.save!
        response = { status: 'success', follow: followURL }
      else
        response = { status: 'fail' }
      end 
      
    else
      response = ["No data"]
    end

    respond_to do |format|
      format.html { render json: response }
      format.json { render json: response }
    end
    
  end
  
  ## POST /experiment_sessions/1
  def uploadCSV
    #Grab the experiment so we can get field names
    @experiment_session = ExperimentSession.new(:experiment_id => params[:id], :title => "#{@cur_user.name}'s Session", :user_id => @cur_user.try(:id))
    @experiment = @experiment_session.experiment
    @data_set = DataSet.all({:experiment_session_id => @experiment_session.id})
    
    header = []
    
    #Read the CSV
    require "csv"
    
    if params[:key].nil?
    
      #Get a link to the temp file uploaded to the server
      @file = params[:csv]
      
      data = CSV.read(@file.tempfile)
    
    else
      
      require "open-uri"
      
      #Grabs the key
      key = params[:key]
      url = "https://spreadsheets.google.com/tq?tqx=out:csv&tq=select*&key=#{key}"
      
      #Use the key to download a csv from docs
      data = open(url).read()

      #strip extra quotes
      data.gsub!( /"/, '' )
      
      #parse as CSV
      data = CSV.parse(data)

    end
    
    data = sortColumns(data, doColumnsMatch(@experiment, data[0]))
    
    #Parse out the headers and the data
    fields = data[0]
    data = data[1..(data.size-1)]
    
    #Data that will be stuffed into mongo
    mongo_data = Array.new
    
    #Build the object that will be displayed in the table
    format_data = {}
    format_data["metadata"] = []
    format_data["data"] = []

    fields.count.times do |i|
      format_data["metadata"].push({name: headers[i], label: headers[i], datatype: "string", editable: true})
    end
    
    header = Field.find_all_by_experiment_id(@experiment.id)
    
    data.each do |dp|
      row = []
      header.each_with_index do |field, col_index|
        row << { "#{field[:id]}" => dp[col_index] }
      end
      mongo_data << row
    end

    if @experiment_session.save!
      data_to_add = DataSet.new(:experiment_session_id => @experiment_session.id, :data => mongo_data)    
    
      if data_to_add.save!
        response = { status: 'success', message: format_data }
      else
        response = { status: 'fail' }
      end
    else
      response = { status: 'fail' }
    end  
      
    #Send the object as json
    respond_to do |format|
      format.json { render json: response }
      format.html { redirect_to :controller => :visualizations, :action => :displayVis, :id => @experiment.id, :sessions => "#{@experiment_session.id}" }
    end
    
  end

private
  #determine whether or not the headers match the file. 
  def doColumnsMatch(experiment, headers)
    fields = experiment.fields
    
    matches = []
    fields.size.times do |i|
      matches[i] = -1
    end
    
    fields.each do |field|
      headers.each do |header|
        if(field.name.size() > header.size())
          smallest = header.size()
        else
          smallest = field.name.size()
        end
        
        size_of_subsequence = lcs(field.name,header).size()
        
        if(size_of_subsequence/smallest > 0.65)
          matches[fields.index(field)] = headers.index(header);
        end
      end
    end

    matches
    
  end
  
  def rotateMatrix(matrix)
    
    newMatrix = []
    
    for i in 0...matrix[0].size()
      newMatrix[i] = []
    end
      
    for i in 0...matrix.size()
      
      for j in 0...matrix[i].size()
        newMatrix[j][i] = matrix[i][j]
      end
    end
    
    newMatrix
    
  end
  
  def sortColumns(rowColMatrix, indexArray)
    rotatedMatrix = rotateMatrix(rowColMatrix)
    indexArray.size.times do |i|
      if indexArray[i] != i
        if(indexArray.index(i) != nil)
          #rowColMatrix = swapColumns(rowColMatrix, i, indexArray.index(i))
          rotatedMatrix[i],rotatedMatrix[indexArray.index(i)] = rotatedMatrix[indexArray.index(i)],rotatedMatrix[i]
          indexArray[indexArray.index(i)],indexArray[i] = indexArray[i],indexArray[indexArray.index(i)]
        end
      end
    end
    rotatedMatrix = rotateMatrix(rotatedMatrix)
    rotatedMatrix  
  end
  
  def lcs(a, b)
      lengths = Array.new(a.size+1) { Array.new(b.size+1) { 0 } }
      # row 0 and column 0 are initialized to 0 already
      a.split('').each_with_index { |x, i|
          b.split('').each_with_index { |y, j|
              if x == y
                  lengths[i+1][j+1] = lengths[i][j] + 1
              else
                  lengths[i+1][j+1] = \
                      [lengths[i+1][j], lengths[i][j+1]].max
              end
          }
      }
      # read the substring out from the matrix
      result = ""
      x, y = a.size, b.size
      while x != 0 and y != 0
          if lengths[x][y] == lengths[x-1][y]
              x -= 1
          elsif lengths[x][y] == lengths[x][y-1]
              y -= 1
          else
              # assert a[x-1] == b[y-1]
              result << a[x-1]
              x -= 1
              y -= 1
          end
      end
      result.reverse
  end
  
end
