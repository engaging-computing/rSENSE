require 'nokogiri'
require 'open-uri'
require 'roo'

class VernierParser
  def convert(path_or_xml)
    if File.exist?(path_or_xml)
      @xml = File.read path_or_xml
    else
      @xml = path_or_xml
    end

    @doc = Nokogiri::HTML(@xml)

    @col = []
    headers = []

    @doc.css('document dataset columncells').each do |col|
      @col.push col.children.to_s.split(/\r?\n/)
    end

    @doc.css('document dataset dataobjectname').each do |header|
      headers.push header.children.to_s
    end

    @col.each_with_index do |col, col_index|
      col.insert(0, headers[col_index])
    end

    rotate

    data = CSV.parse(csv)

    data
  end

  def data
    @row
  end

  def rotate
    row = []

    @col[0].each_with_index do |col_row, row_index|
      new_row = []

      @col.each_with_index do |cur, cur_index|
        new_row.push @col[cur_index][row_index]
      end

      row.push new_row
    end

    @row = row
  end

  def row(row_id)
    if row_id >= 0 and row_id < last_row
      return @row[row_id]
    else
      return []
    end
  end

  def column(col_id)
    if col_id >= 0 and col_id < last_column
      return @col[col_id]
    else
      return []
    end
  end

  def last_column
    @col.size
  end

  def last_row
    @row.size
  end

  def to_csv
    rows = []

    @row.each_with_index do |row, row_index|
      rows.push @row[row_index].join "\",\""

      rows[row_index].insert(0, "\"")
      rows[row_index] << "\""
    end

    rows = rows.join "\n"

    rows << "\n"
  end

  private

  def write_temp_file(data)
    # Create a tmp directory if it does not exist
    begin
      Dir.mkdir('/tmp/rsense')
    rescue
    end

    # Save file so we can grab it again
    base = '/tmp/rsense/dataset'
    fname = base + "#{SecureRandom.hex}.csv"

    File.open(fname, 'w') do |ff|
      ff.write(data)
    end

    fname
  end
end

