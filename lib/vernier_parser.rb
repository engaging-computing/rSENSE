require 'nokogiri'
require 'open-uri'

class VernierParser

  def initialize(path_or_xml)
    if File.exists?( path_or_xml )
      @xml = File.read path_or_xml
    else
      @xml = path_or_xml
    end
    
    @doc = Nokogiri::HTML(@xml)
    
    @col = []
    
    @doc.css('document dataset columncells').each do |col|
      @col.push col.children.to_s.split( /\r?\n/ )
    end
    
    self.rotate
    
    self.data
    
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
  
  def row( row_id )
    if row_id >= 0 and row_id < self.last_column
      return @row[row_id]
    else
      return []
    end
  end
  
  def column( col_id )
    if col_id >= 0 and col_id < self.last_row
      return @col[col_id]
    else
#       return []
    end
  end
  
  def last_column
    return @col.size()
  end
  
  def last_row
    return @row.size()
  end

end