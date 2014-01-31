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
    
    @cols = []
    
    @doc.css('document dataset columncells').each do |col|
      @cols.push col.children.to_s.split( /\r?\n/ )
    end
    
  end
  
  def data
    return @cols
  end
  

end