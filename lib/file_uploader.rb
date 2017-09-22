# File upload functions
require 'csv'
require 'roo'
require 'open-uri'
require 'fileutils'

class FileUploader
  class << self; attr_accessor :upload_whitelist end

  @upload_whitelist = [
    # Text
    'txt', 'rtf', 'xml', 'pdf', 'csv', 'tsv', 'ltsv', 'yaml', 'tab', 'json', 'log', 'xps', 'ps', 'asc',
    # Word
    'doc', 'docx', 'dot', 'docm',
    # Excel
    'xls', 'xlsx', 'xlt', 'dif', 'dfb', 'slk', 'xlsm', 'xlk', 'xlsb', 'xlr', 'xltm', 'xlw',
    # Powerpoint
    'ppt', 'pptx', 'ppsx', 'potm', 'pps', 'pot', 'pptm',
    # LibreOffice Word
    'odt', 'fodt', 'uot',
    # LibreOffice Excel
    'ods', 'ots', 'fods', 'uos',
    # LibreOffice Powerpoint
    'odp', 'otp', 'odg', 'fodp', 'uop',
    # LibreOffice Draw
    'otg', 'fodg',
    # Math
    'odf', 'mml',
    # Images
    'png', 'svg', 'jpg', 'jpeg', 'bmp', 'tif', 'psd', 'pdd', 'ico', 'jng',
    # Web
    'xml',
    # Presentation
    'pez', 'sti', 'sxi',
    # Google
    'gdoc', 'gsheet',
    # App Inventor
    'aia'
  ]

  @converted_csv = nil

  ### Generates the object that will be acted on
  def generateObject(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet[0]
    data_obj = {}
    data_obj['data'] = {}
    (0..header.length - 1).each do |i|
      data_obj['data'][header[i]] = ''
    end

    data_obj[:file] =  write_temp_file(spreadsheet)

    data_obj
  end

  def generateObjectForTemplateUpload(file)
    row_major = open_spreadsheet(file)
    headers = row_major[0]
    column_major = row_major[1..row_major.length].transpose

    data_obj = {}
    data = {}

    (0..headers.length - 1).each do |i|
      data[headers[i]] = column_major[i]
    end

    data_obj[:types] = get_probable_types(data)
    data_obj[:file] =  write_temp_file(row_major)
    data_obj[:headers] = headers
    data_obj[:has_data] = !data.first[1].nil?
    data_obj
  end

  ### Simply opens the file as the correct type and returns the Roo object.
  def open_spreadsheet(file)
    if file.class == ActionDispatch::Http::UploadedFile
      case File.extname(file.original_filename)
      when '.csv', '.txt', '.text' then convert(file.path)
      when '.xls', '.xlsx', '.ods'
        system "libreoffice --calc --headless --nologo --invisible --convert-to csv #{file.path} --outdir /tmp/rsense > /dev/null 2>&1"
        @converted_csv = "/tmp/rsense/#{file.path.gsub('/tmp/', '')}.csv"
        convert(@converted_csv)
      when '.gpx' then GpxParser.new.convert(file.path)
      when '.qmbl' then VernierParser.new.convert(file.path)
      else fail "Unknown file type: #{file.original_filename}"
      end
    else
      x = write_temp_file(CSV.parse(open(file) { |f| f.read }))
      if File.size(x) > 10000000
        fail 'Maximum upload size of a single data set is 10 MB. Please split your file into multiple pieces and upload them individually.'
      end
      spreadsheet = convert(x)
      cleanup_temp_file(x)
      spreadsheet
    end
  end

  ### Retrieve Object
  def retrieve_obj(file)
    spreadsheet = convert(file)
    header = spreadsheet.shift
    data_obj = {}
    spreadsheet = spreadsheet.transpose
    (0..(header.length - 1)).each do |i|
      data_obj[header[i]] = spreadsheet[i]
    end
    data_obj
  end

  ## Swap columns
  def swap_columns(data_obj, project)
    data = []

    largest = data_obj.to_a.reduce [] do |a, b|
      a.length > b[1].length ? a : b[1]
    end
    size = largest.length

    (0..size - 1).each do |i|
      x = {}
      project.fields.each do |field|
        next unless data_obj.key?(field.id.to_s)
        x[field.id] = data_obj[field.id.to_s][i]
      end
      data << x
    end
    data
  end

  def swap_with_field_names(data_obj, project)
    # data_obj is a JSON object where the keys are the names of the
    # fields and the values are the data in the column underneath
    # the field names
    data = []

    # data_obj.first gets the first key-value pair, and [1]
    # looks at the data (the value) of the pair - if there is
    # no data, return the empty array
    if data_obj.first[1].nil?
      return data
    end

    size = data_obj.first[1].length

    (0..size - 1).each do |i|
      x = {}
      project.fields.each do |field|
        x[field.id] = data_obj[field.name][i]
      end
      data << x
    end
    data
  end

  ### Match headers should return a match_matrix for mismatches or continue
  def match_headers(project, data_obj)
    fields = project.fields.map { |fi| fi.to_hash(false) }

    if data_obj.key?('data')
      headers = data_obj['data'].keys
    else
      headers = data_obj.keys
    end

    matrix = []
    fields.each_with_index do |f, fi|
      matrix.append []
      headers.each_with_index do |h, hi|
        lcs_length = lcs(f[:name].downcase, headers[hi].downcase).length.to_f
        x = lcs_length / f[:name].length.to_f
        y = lcs_length / headers[hi].length.to_f
        avg = (x + y) / 2
        matrix[fi].append avg
      end
    end

    results = {}
    results[:partial_matches] = {}

    results[:options] = []
    results[:options][0] = ['Select One', 0]

    headers.each_with_index do |h, i|
      results[:options][i + 1] = [h, h]
    end

    i = 0
    loop do
      max = matrixMax(matrix)

      break if max['val'] == 0
      matrixZeroCross(matrix, max['findex'], max['hindex'])

      results[:partial_matches][max['findex']] = { index: max['hindex'], quality: max['val'] }
      i += 1
    end

    results[:file] = data_obj[:file]
    results[:fields] = fields
    results[:headers] = headers
    if results.size != project.fields.size
      results[:status] = false
    else
      results[:status] = true
    end

    results
  end

  def get_probable_types(data_set)
    types = {}
    types['text'] = []
    types['timestamp'] = []
    types['latitude'] = []
    types['longitude'] = []

    yyyymmdd = %r{((?<year>\d{4})( |-|\/)(?<month>\d{1,2})( |-|\/)(?<day>\d{1,2})|([uU]\s\d+))}
    mmddyyyy = %r{((?<month>\d{1,2})( |-|\/)(?<day>\d{1,2})( |-|\/)(?<year>\d{4})|([uU]\s\d+))}

    data_set.each do |column|
      # if the data is not nil and matches the timestamp regex, or if the data
      # is nil but the header contains "time," classify as a timestamp
      if (!column[1].nil? and
           (column[1]).map { |dp| (yyyymmdd =~ dp) or (mmddyyyy =~ dp) }.reduce(:&)) or
         (column[1].nil? and column[0].upcase.include?('TIME'))
        types['timestamp'].push column[0]
        next
      end
      # try a header match for latitude and longitude
      if column[0].casecmp('LATITUDE') == 0 or column[0].casecmp('LAT') == 0
        types['latitude'].push column[0]
        next
      end
      if column[0].casecmp('LONGITUDE') == 0 or column[0].casecmp('LON') == 0
        types['longitude'].push column[0]
        next
      end
      # if there is data and the data is a valid float, classify as text
      if !column[1].nil? &&
         !(column[1]).map { |dp| valid_float?(dp) }.reduce(:&)
        types['text'].push column[0]
      end
      # if no match was found above, this defaults to number
    end
    types
  end

  def sanitize_data(data_obj, matches = nil)
    if !matches.nil?
      data = {}
      matches.each do |match|
        column = data_obj[match[1]]
        next if column.nil?
        field = Field.find(match[0])
        data[field.id.to_s] = column
      end
    else
      data = data_obj
    end

    if data == {}
      return { status: false, msg: 'Empty Data Set' }
    end

    data_obj = remove_empty_lines(data_obj)
    remove_keys = []

    data.each do |(key, value)|
      field = Field.find_by_id(key)
      if field.nil?
        remove_keys.push(key)
        next
      end

      type = get_field_name(field.field_type)
      value.each_with_index do |dp, index|
        if dp.nil? or (dp.to_s.strip == '')
          data[key][index] = ''
          next
        end

        case type
        when 'Number'
          unless valid_float?(dp)
            err_msg = "'#{field.name}' should contain only numbers, found '#{dp}'"
            return { status: false, msg: err_msg }
          end
        when 'Latitude'
          if valid_float?(dp)
            next if (Float dp).abs <= 90
          end
          return { status: false, msg: 'Latitude contains invalid data' }
        when 'Longitude'
          if valid_float?(dp)
            next if (Float dp).abs <= 180
          end
          return { status: false, msg: 'Longiude contains invalid data' }
        when 'Timestamp'
        when 'Text'
          unless field.restrictions.length == 0
            unless field.restrictions.map { |r| r.downcase.gsub(/\s+/, '') }.include? dp.downcase.gsub(/\s+/, '')
              data[key][index] = ''
            end
          end
        end
      end
    end

    remove_keys.each do |key|
      data.delete(key)
    end

    { status: true, msg: 'passed', data_obj: data }
  end

  private

  def cleanup_temp_file(filename)
    FileUtils.rm(filename, force: true)
  rescue
    # do nothing
  end

  def write_temp_file(data)
    # Create a tmp directory if it does not exist

    begin
      Dir.mkdir('/tmp/rsense')
    rescue
    end

    # if an item has a comma in it, then surround it with quotes
    # This prevents one item from being separated into two
    # the "respond_to" protects against the situation where there is a nil or non-string object where it shouldn't be
    data = data.map { |row| row.map { |x| (x.respond_to?(:include?) and x.include?(',')) ? '"' + x + '"' : x } }
    # Save file so we can grab it again
    base = '/tmp/rsense/dataset'
    fname = base + "#{SecureRandom.hex}.csv"
    f = File.new(fname, 'w')
    as_csv = data.map { |y| y.join(',') }.join("\n")
    f.write(as_csv)
    f.close

    fname
  end

  # Returns the index of the highest value in the match matrix.
  def matrixMax(matrix)
    n = matrix.map do |x|
      m = {}
      m['val'] = x.max
      m['hindex'] = x.index(m['val'])
      m['findex'] = matrix.index(x)
      m
    end

    n.reduce do |h1, h2|
      if h1['val'] > h2['val']
        h1
      else
        h2
      end
    end
  end

  # Zero out a row and column of the match matrix
  def matrixZeroCross(matrix, findex, hindex)
    (0...matrix.size).each do |fi|
      matrix[fi][hindex] = 0
    end

    (0...matrix[0].size).each do |hi|
      matrix[findex][hi] = 0
    end

    matrix
  end

  # Longest common subsequence. Used in column matching
  def lcs(a, b)
    lengths = Array.new(a.size + 1) { Array.new(b.size + 1) { 0 } }
    # row 0 and column 0 are initialized to 0 already
    a.split('').each_with_index do |x, i|
      b.split('').each_with_index do |y, j|
        if x == y
          lengths[i + 1][j + 1] = lengths[i][j] + 1
        else
          lengths[i + 1][j + 1] = \
            [lengths[i + 1][j], lengths[i][j + 1]].max
        end
      end
    end

    # read the substring out from the matrix
    result = ''
    x = a.size
    y = b.size
    while x != 0 and y != 0
      if lengths[x][y] == lengths[x - 1][y]
        x -= 1
      elsif lengths[x][y] == lengths[x][y - 1]
        y -= 1
      else
        # assert a[x-1] == b[y-1]
        result << a[x - 1]
        x -= 1
        y -= 1
      end
    end

    result.reverse
  end

  def convert(filepath)
    data = CSV.parse(File.read(filepath))

    headers = data[0].map(&:downcase)
    overlap = headers.uniq.map { |e| [headers.count(e), e] }.select { |c, _| c > 1 }.map { |c, e| "found #{c} #{e} column(s) " }

    if headers.map(&:downcase).uniq.count == headers.count
      data
    else
      fail overlap.to_s
    end
  end

  def valid_float?(dp)
    return true if dp.nil?
    Float(dp)
    true
  rescue
    false
  end

  def remove_empty_lines(data_obj)
    row = data_obj.first[1].length
    keys = data_obj.keys

    while row >= 0
      row_empty = keys.map { |k| (data_obj[k][row].nil? or (data_obj[k][row].to_s.strip == '')) }.reduce(:&)
      if row_empty
        keys.map { |k| data_obj[k].delete_at(row) }
      end
      row -= 1
    end
    data_obj
  end
end
