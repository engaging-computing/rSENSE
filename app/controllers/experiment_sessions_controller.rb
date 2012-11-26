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
  
  # POST /experiment_session/1/manualUpload
  def manualUpload
    
    @experiment_session = ExperimentSession.find(params[:id])
    
    #pulls fields from post
    header = params[:header]
    #pulls data as array from post
    rows = params[:data]
    data = Array.new
    
    #data = associative array of header and rows
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
    
    #remove old data
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
  
  ## POST /experiment_sessions/1
  def postCSV
    #Grab the experiment so we can get field names
    @experiment_session = ExperimentSession.find(params[:id])
    @experiment = @experiment_session.experiment
    @data_set = DataSet.all({:experiment_session_id => @experiment_session.id})
    
    unless @data_set.nil?
      @data_set.each do |old_data|
        old_data.destroy
      end
    end
    
    
    #Get a link to the temp file uploaded to the server
    @file = params[:experiment_session][:file]
    
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
