#File upload functions 
require 'csv'
require 'roo'
require 'open-uri'
require 'fileutils'

class FileUploader

  ### Generates the object that will be acted on
  def generateObject(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    data_obj = Hash.new
    data_obj['data'] = Hash.new
    (0..spreadsheet.last_column-1).each do |i|
      data_obj['data'][header[i]] = spreadsheet.column(i+1)[1,spreadsheet.last_row]
    end
    
    data_obj[:file] =  write_temp_file(CSV.parse(spreadsheet.to_csv))

    data_obj
  end
  
  ### Simply opens the file as the correct type and returns the Roo object.
  def open_spreadsheet(file)
    if file.class == ActionDispatch::Http::UploadedFile
      Rails.logger.info "-=-=-=#{file.path}"
      case File.extname(file.original_filename)
      when ".csv" then convert(file.path)
      when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
      when ".xlsx" then Roo::Excelx.new(file.path,nil,:ignore)
      when ".ods" then Roo::OpenOffice.new(file.path,false,:ignore)
      when ".gpx" then GpxParser.new.convert(file.path)
      else raise "Unknown file type: #{file.original_filename}"
      end
    else
      x = write_temp_file(CSV.parse(open(file) {|f| f.read}))
      spreadsheet = convert(x)
      cleanup_temp_file(x)
      spreadsheet
    end
  end
  
  ### Retrieve Object
  def retrieve_obj(file)
    spreadsheet = convert(file)
    header = spreadsheet.row(1)
    
    data_obj = Hash.new
   
    (0..spreadsheet.last_column-1).each do |i|
      data_obj[header[i]] = spreadsheet.column(i+1)[1,spreadsheet.last_row]
    end
    
    data_obj    
  end
  
  ## Swap columns 
  def swap_columns(data_obj, project, matches) 
    size = data_obj.first[1].length
    data = []
    (0..size-1).each do |i|
      x = {}
      project.fields.each do |field|
        next if matches[field.id.to_s] == "0"
        x[field.id] = data_obj[matches[field.id.to_s]][i]
      end
      data << x
    end
    
    data
  end
  
  def swap_without_matches(data_obj,project)
    data = []
    size = data_obj.first[1].length

    (0..size-1).each do |i|
      x = {}
      project.fields.each do |field|
        x[field.id] = data_obj[field.name][i]
      end
      data << x
    end
    data
  end
  
  ### Match headers should return a match_matrix for mismatches or continue
  def match_headers(project,data_obj)
    fields = project.fields
    
    if data_obj.has_key?('data')
      headers = data_obj['data'].keys
    else
      headers = data_obj.keys
    end
    
    matrix = []
    fields.each_with_index do |f,fi|
      matrix.append []
      headers.each_with_index do |h,hi|
        lcs_length = lcs(f.name.downcase,headers[hi].downcase).length.to_f
        x = lcs_length / f.name.length.to_f
        y = lcs_length / headers[hi].length.to_f
        avg = (x + y) / 2
        matrix[fi].append avg
      end
    end
    
    results = {}
    results[:partial_matches] = {}
    
    results[:options] = []
    results[:options][0] = ['Select One',0]
    
    headers.each_with_index do |h,i|
      results[:options][i+1] = [h,h]
    end
    
    worstMatch = 0
    i=0;
    until false
      max =  matrixMax(matrix)

      break if max['val'] == 0
      matrixZeroCross(matrix, max['findex'], max['hindex'])

      results[:partial_matches][max['findex']] = {:index => max['hindex'], :quality => max['val']}
      i += 1
    end
    
    results[:file] = data_obj[:file]
    results[:fields] = fields
    results[:headers] = headers
    if (results.size != project.fields.size) or (worstMatch < 0.6)
      results[:status] = false
    else
      results[:status] = true
    end
    
    results
  end
  
  def sanitize_data(data_obj, project, matches)
    matches.each do |match|
      field = Field.find(match[0])
      type = get_field_name(field.field_type)
      column = data_obj[match[1]]
      column.each do |dp|
        case type
        when "Number"
          return {status: false, msg: "\"#{field.name}\" should contain only numbers, found \"#{dp}\""} if !dp.valid_float?
        when "Latitude"
          if dp.valid_float?
            next if ((Float dp).abs <= 90)
          end
          return {status: false, msg: "Latitude contains invalid data"}
        when "Longitude"
          if dp.valid_float?
            next if ((Float dp).abs <= 180)
          end
          return {status: false, msg: "Longiude contains invalid data"}
        when "Time"
        when "Text"
        end
      end
    end
    return {status: true, msg: "passed"}
  end
  
  
  private
  
  def cleanup_temp_file(filename)
    begin
      FileUtils.rm(filename, force: true)
    rescue
    end
  end
  
  def write_temp_file(data)
    #Create a tmp directory if it does not exist
      begin
        Dir.mkdir("/tmp/rsense")
      rescue
      end

      #Save file so we can grab it again
      base = "/tmp/rsense/dataset"
      fname = base + "#{Time.now.to_i}.csv"
      f = File.new(fname, "w")
      
       y = ""
      data.each do |x|
        y += x.join(",") + "\n"
      end
      f.write(y)

      f.close
      
      fname
  end
  
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
  
    
  
  def convert( filepath )
    possible_separators = [",", "\t", ";"]
    
    #delimters
    delim = Array.new
    
    possible_separators.each_with_index do |sep, index|
      
      delim[index] = Hash.new
      delim[index][:input] = filepath
      delim[index][:file] = Roo::CSV.new( filepath, csv_options: {col_sep: sep, quote_char: "\'"})
      delim[index][:data] = delim[index][:file].parse()
      delim[index][:avg] = 0
      
      delim[index][:data].each do |row|
        delim[index][:avg] = delim[index][:avg] + row.count
      end
      
      delim[index][:avg] = delim[index][:avg] / delim[index][:data].count
      
    end
        
    possible_separators.each_with_index do |sep, index|
      if( delim[index][:data].first.count == delim[index][:avg] and delim[index][:data].last.count == delim[index][:avg] and delim[index][:avg] > 1)
        
        return delim[index][:file]
        
      end
    end
    
    delim[0][:file]
    
  end
  
end

class String
  def valid_float?
    true if Float self rescue false
  end
end