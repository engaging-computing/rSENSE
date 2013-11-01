#File upload functions 
class FileUploader
  require 'csv'
  require 'iconv'
  require 'roo'

  ### Generates the object that will be acted on
  def generateObject(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    data_obj = Hash.new
    data_obj['data'] = Hash.new
    (0..spreadsheet.last_column-1).each do |i|
      data_obj['data'][header[i]] = spreadsheet.column(i+1)[1,spreadsheet.last_row]
    end
    
    #Temporary to pull stuff out of controller
    data = CSV.parse(spreadsheet.to_csv)
    data_obj['old_data'] = data
    data_obj['file'] = file.path
    
    data_obj
  end
  
  ### Simply opens the file as the correct type and returns the Roo object.
  def open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path,nil,:ignore)
    when ".ods" then Roo::OpenOffice.new(file.path,false,:ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
  ### Match headers should return a match_matrix for mismatches or continue
  def match_headers(project,data_obj)
    fields = project.fields.map {|n| n.name}
    headers = data_obj['data'].keys
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
    
    results = {}
    worstMatch = 0
    until false
      max =  matrixMax(matrix)

      break if max['val'] == 0
      matrixZeroCross(matrix, max['findex'], max['hindex'])

      results[max['findex']] = {findex: max['findex'], hindex: max['hindex'], quality: max['val']}
      worstMatch = max['val']
    end
    
    if (results.size != project.fields.size) or (worstMatch < 0.6)
      Rails.logger.info "Should launch match columns"
    end
    
    ret = Hash.new
    ret['results'] = results.size
    ret['worstMatch'] = worstMatch
    ret
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
  
end