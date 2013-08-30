class DataSetsController < ApplicationController

  include ApplicationHelper

  # GET /data_sets/1
  # GET /data_sets/1.json
  def show
    @data_set = DataSet.find(params[:id])
    @mongo_data_set = MongoData.find_by_data_set_id(@data_set.id)
    recur = params.key?(:recur) ? params[:recur].to_bool : false
    respond_to do |format|
      format.html { redirect_to (project_path @data_set.project) + (data_set_path @data_set) }
      format.json { render json: @data_set.to_hash(recur)}
    end
  end

  # GET /data_sets/new
  # GET /data_sets/new.json
  def new
    @data_set = DataSet.new

    respond_to do |format|
      format.html
      format.json { render json: @data_set.to_hash(false) }
    end
  end

  # GET /data_sets/1/edit
  def edit
    @data_set = DataSet.find(params[:id])
    @project = Project.find(@data_set.project_id)
    @mongo_data_set = MongoData.find_by_data_set_id(@data_set.id)
    @fields = @project.fields

    header_to_field_map = []

    if !params["data"].nil? and !params["headers"].nil?
      @project.fields.each do |field|
        params["headers"].each_with_index do |header, header_index|
          if header.to_i == field.id
            header_to_field_map.push header_index
          end
        end
      end

      new_data = []

      params["data"]["0"].each_with_index do |tmp, row_index|

        row = {}

        header_to_field_map.each do |htf, htf_index|
          if params["data"]["#{htf}"][row_index] == ""
            if @fields[htf].field_type == 3
              val = ""
            else
              val = nil
            end
          else
            val = params["data"]["#{htf}"][row_index]
          end
          row["#{@fields[htf].id}"] = val
        end


        new_data[row_index] = row

      end

      @mongo_data_set[:data] = new_data

      if @mongo_data_set.save!
        ret = { status: :success, redirect: "/projects/#{@project.id}/data_sets/#{@data_set.id}" }
      else
        ret = :error
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: ret }
    end

  end

  # POST /data_sets
  # POST /data_sets.json
  def create
    @data_set = DataSet.new(params[:data_set])

    respond_to do |format|
      if @data_set.save
        format.html { redirect_to @data_set, notice: 'Project data set was successfully created.' }
        format.json { render json: @data_set.to_hash(false), status: :created, location: @data_set }
      else
        format.html { render action: "new" }
        format.json { render json: @data_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /data_sets/1
  # PUT /data_sets/1.json
  def update
    @data_set = DataSet.find(params[:id])
    editUpdate  = params[:data_set]
    hideUpdate  = editUpdate.extract_keys!([:hidden])
    success = false

    #EDIT REQUEST
    if can_edit?(@data_set)
      success = @data_set.update_attributes(editUpdate)
    end

    #HIDE REQUEST
    if can_hide?(@data_set)
      success = @data_set.update_attributes(hideUpdate)
    end

    respond_to do |format|
      if @data_set.update_attributes(params[:data_set])
        format.html { redirect_to @data_set, notice: 'DataSet was successfully updated.' }
        format.json { render json: {}, status: :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @data_set.errors.full_messages(), status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data_sets/1
  # DELETE /data_sets/1.json
  def destroy
    @data_set = DataSet.find(params[:id])

    if can_delete?(@data_set)

      @data_set.media_objects.each do |m|
        m.destroy
      end

      @data_set.hidden = true
      @data_set.user_id = -1
      @data_set.project_id = -1
      @data_set.save

      respond_to do |format|
        format.html { redirect_to @data_set.project }
        format.json { render json: {}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to 'public/401.html' }
        format.json { render json: {}, status: :forbidden }
      end
    end
  end

  def manualEntry
    @project = Project.find(params[:id])
  end

  # POST /data_set/1/manualUpload
  def manualUpload

    ############ Sanity Checks ############
    errors = []
    sane = true
    
    if params[:data].nil?
      errors.push "'data' cannot be nil."
      sane = false
    end
    
    if params[:headers].nil?
      errors.push "'headers' cannot be nil."
      sane = false
    end
    
    if params[:id].nil?
      errors.push "'id' cannot be nil."
      sane = false
    end
    
    if sane && !(params[:data].length == params[:headers].length)
      errors.push "Number of data columns (#{params[:data].length}) does not match number of headers (#{params[:headers].length})."
      sane  = false
    end
    
    if !sane
      #insane in the membrane
      respond_to do |format|
        format.json { render json: errors, status: :unprocessable_entity }
      end
      return
    end
    #######################################
    
    @project = Project.find(params[:id])
    @fields = @project.fields
    header_to_field_map = {}
    success = false
    defaultName = ""
    
    if !params[:name]
      defaultName  = @project.title + " Dataset #"
      defaultName += (DataSet.find_all_by_project_id(params[:id]).count + 1).to_s
    else
      defaultName = params["name"]
    end

    # Generate field mappings
    @project.fields.each do |field|
      params[:headers].each_with_index do |header, header_index|
        if header.to_i == field.id
          header_to_field_map["#{field.id}"] =  header_index
        end
      end
    end
    
    if header_to_field_map.count != @fields.count
      #headers dont match... womp womp wahhhhh
      errors.push "Number of headers (#{header_to_field_map.count}) does not match the number of fields (#{@fields.count})"
      respond_to do |format|
        format.json { render json: errors, status: :unprocessable_entity }
      end
      return
    end
    
    # Format data
    new_data = []

    params[:data]["0"].each_with_index do |tmp, row_index|

      row = {}

      header_to_field_map.each do |key, value|
        if params["data"]["#{value}"][row_index] == ""
          if @fields.find(key.to_i).field_type == 3
            val = ""
          else
            val = nil
          end
        else
          val = params["data"]["#{value}"][row_index]
        end
        row["#{key}"] = val
      end


      new_data[row_index] = row

    end

    @data_set = DataSet.create(:user_id => @cur_user.id, :project_id => @project.id, :title => defaultName)
    data_to_add = MongoData.new(:data_set_id => @data_set.id, :data => new_data)

    followURL = "/projects/#{@project.id}/data_sets/#{@data_set.id}"

    success =  data_to_add.save!
    
    if !success
      @data_set.delete
    end


    respond_to do |format|
      if success
        format.json { render json: @data_set.to_hash(false), status: :created}
      else
        format.json { render json:{}, status: :unprocessable_entity }
      end
    end

  end

  def export

    #require 'CSV'
    require 'tempfile'

    @project = Project.find params[:id]
    @datasets = []

    # build list of datasets
    if( !params[:datasets].nil? )

      dsets = params[:datasets].split(",")
      dsets.each do |s|
        begin
          @datasets.push DataSet.find_by_id_and_project_id s, params[:id]
        rescue
          logger.info "Either project id or dataset does not exist in the DB"
        end
      end
    else
      @datasets = DataSet.find_all_by_project_id params[:id]
    end


    @datasets.each do |dataset|
      mongo_data = MongoData.find_by_data_set_id dataset.id
      dataset[:data] = mongo_data.data
    end

    file_name = "#{@project.id}"

    @datasets.each do |dataset|
      file_name = file_name + "_#{dataset.id}"
    end

    tmp_file = File.new("./tmp/#{file_name}.csv", 'w+')

    @project.fields.each_with_index do |field, f_index|
      tmp_file.write field[:name]

      if( f_index != @project.fields.count )
        tmp_file.write ", "
      end
    end

    tmp_file.write "\n"

    @datasets.each_with_index do |data_set, d_index|

      data_set[:data].each_with_index do |data_row, dr_index|

        data_row.each_with_index do |data_point, dp_index|

          tmp_file.write data_point[1]

          if( dp_index = data_row.count )
            tmp_file.write ", "
          end

        end

        tmp_file.write "\n"

      end

    end

    tmp_file.close

    respond_to do |format|
      format.html { send_file tmp_file.path, :type => 'text/csv' }
    end

  end


  ## POST /data_sets/1
  def uploadCSV
    require "csv"
    require "open-uri"
    
    @project = Project.find(params[:id])
    fields = @project.fields
    exp_fields = []
    fields.each do |f|
      exp_fields.append f.name
    end
    fields = exp_fields

    #Client has responded to a call for matching
    if(params.has_key?(:matches))

      data = CSV.read(params['tmpFile'])

      headers = params[:headers]
      matches = params[:matches]

      matches = matches.inject({}) do |acc, kvp|
        v = kvp[1].inject({}) do |acc, kvp|
          acc[kvp[0].to_sym] = Integer(kvp[1])
          acc
        end

        acc[Integer(kvp[0])] = v
        acc
      end

      data = sortColumns(data, matches)

    #First call to upload a csv.
    else
      isdoc = false
      if params.has_key? :csv
        @file = params[:csv]
        data = CSV.read(@file.tempfile)
      else 
        tempfile = CSV.new(open(params[:tmpfile]))
        data = tempfile.read()
        isdoc = true
      end
      
      headers = data[0]

      #Build match matrix with quality
      matrix = buildMatchMatrix(fields,headers)
      results = {}
      worstMatch = 0
      until false
        max =  matrixMax(matrix)

        break if max['val'] == 0
        matrixZeroCross(matrix, max['findex'], max['hindex'])

        results[max['findex']] = {findex: max['findex'], hindex: max['hindex'], quality: max['val']}
        worstMatch = max['val']
      end

      # If the headers are mismatched respond with mismatch
      if (results.size != @project.fields.size) or (worstMatch < 0.6)
        #Create a tmp directory if it does not exist
        begin
          Dir.mkdir("/tmp/rsense")
        rescue
        end

        #Save file so we can grab it again
        base = "/tmp/rsense/dataset"
        fname = base + "#{Time.now.to_i}.csv"
        f = File.new(fname, "w")
        
        if !isdoc #Not from a google doc
          f.write @file.tempfile.read
        else #From a Google Doc
          y = ""
          data.each do |x|
            y += x.join(",") + "\n"
          end
          f.write(y)
        end
        f.close
        
        respond_to do |format|
          format.json { render json: {pid: params[:id],headers: headers, fields: fields, partialMatches: results,tmpFile: fname}, status: :partial_content  }
        end
        return

      #EVERYTHING MATCHED, SORT THE COLUMNS
      else
        data = sortColumns(data,results)
      end
    end

    #WE HAVE SUCCESSFULLY MATCHED HEADERS AND FIELDS, SAVE THE DATA FINALLY.
    @project = Project.find_by_id(params[:id])
    
    if(!params.try(:[], :dataset_name))
      defaultName  = @project.title + " Dataset #"
      defaultName += (DataSet.find_all_by_project_id(params[:id]).count + 1).to_s
    else 
      defaultName = params[:dataset_name]
    end

    @data_set = DataSet.new(:project_id => params[:id], :title => defaultName, :user_id => @cur_user.try(:id))

    #Parse out just the data
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

    header = Field.find_all_by_project_id(@project.id)

    data.each do |dp|
      row = {}
      header.each_with_index do |field, col_index|
        row["#{field[:id]}"] = dp[col_index]
      end
      mongo_data << row
    end

    success = false
    
    if @data_set.save!
      data_to_add = MongoData.new(:data_set_id => @data_set.id, :data => mongo_data)

      redirect = url_for :controller => :visualizations, :action => :displayVis, :id => @project.id, :datasets => @data_set.id

      if data_to_add.save!
        success = true
        response = { status: 'success', redirect: redirect, :datasets => @data_set.id, :title => @data_set.title }
      else
        success = false
        @data_set.delete
      end
    else
      success = false
    end
    
    respond_to do |format|
      if success
        format.json { render json: @data_set.to_hash(false), status: :created}
        format.html { redirect_to :controller => :visualizations, :action => :displayVis, :id => @project.id, :datasets => @data_set.id, :title =>  @data_set.title }
      else
        format.json { render json: @data_set.errors.full_messages(), status: :unprocessable_entity }
      end
    end

  end

private

  #Returns the index of the highest value in the match matrix.
  def matrixMax(matrix)

    n = matrix.map do |x|
      m = {}
      m['val'] = x.max
      m['hindex'] = x.index(m['val'])
      m['findex'] = matrix.index(x)
      m
    end

    n.inject do |h1, h2|
      if h1['val'] > h2['val']
        h1
      else
        h2
      end
    end
  end

  #Zero out a row and column of the match matrix
  def matrixZeroCross(matrix, findex, hindex)

    (0...matrix.size).each do |fi|
      matrix[fi][hindex] = 0
    end

    (0...matrix[0].size).each do |hi|
      matrix[findex][hi] = 0
    end

    matrix
  end

  #Use LCS to build a matches with quality.
  def buildMatchMatrix(fields, headers)
    matrix = []
    fields.each_with_index do |f,fi|
      matrix.append []
      headers.each_with_index do |h,hi|
        lcs_length = lcs(fields[fi].downcase,headers[hi].downcase).length.to_f
        x = lcs_length / fields[fi].length.to_f
        y = lcs_length / headers[hi].length.to_f
        avg = (x + y) / 2
        matrix[fi].append avg
      end
    end
    matrix
  end

  #Longest common subsequence. Used in column matching
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

  #It is easier to swap columns around after rotating the data matrix
  def rotateDataMatrix(dataMatrix)

    newDataMatrix = []

    for i in 0...dataMatrix[0].size()
      newDataMatrix[i] = []
    end

    for i in 0...dataMatrix.size()

      for j in 0...dataMatrix[i].size()
        newDataMatrix[j][i] = dataMatrix[i][j]
      end
    end

    newDataMatrix

  end

  #Rotate the matrix then swap the columns to the correct order
  def sortColumns(rowColMatrix, matches)
    rotatedMatrix = rotateDataMatrix(rowColMatrix)
    newData = []

    matches.size.times do |i|
      newData[i] = rotatedMatrix[matches[i][:hindex]]
    end

    rotateDataMatrix(newData)
  end

end
