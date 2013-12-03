require 'nokogiri'
require 'fileutils'
require 'roo'

class GpxParser
  def convert(filepath)

    doc = Nokogiri::XML(File.open(filepath))
    
    trkpts = doc.css("trkpt")
    
    csv = "" 
    headers = trkpts.first.attributes
    
    #Grab attributes from the first trkpt for headers
    trkpts.first.attributes.each do |header|
      csv += header[0] + ","
    end
    
    #Grab contents from the first trkpt for headers
    elements = []
    trkpts.first.children.each do |pt|
      if (pt.class == Nokogiri::XML::Element) && (pt.name != "extensions")
        csv += pt.name + ","
        elements << pt.name
      end
    end
    csv = csv.chomp(",")
    csv += "\n"
    
    trkpts.each do |pt|
      line = ""
      
      #Grab headers out of attributes for each trkpt
      headers.each do |h|
        line += "#{pt.attribute(h[0])},"
      end
      
      #Grab contents out of each trkpt  
      elements.each do |e|
        line += "#{pt.search(e).first.content},"
      end
      line = line.chomp(",")
      line += "\n"
      
      #Add line to csv
      csv += line
    end
    
    filename = write_temp_file(csv)
    
    roo = Roo::CSV.new(filename)

    roo
    
  end
  
  private
 
  def write_temp_file(data)
    #Create a tmp directory if it does not exist
      begin
        Dir.mkdir("/tmp/rsense")
      rescue
      end

      #Save file so we can grab it again
      base = "/tmp/rsense/dataset"
      fname = base + "#{SecureRandom.hex}.csv"
      f = File.new(fname, "w")
      
      f.write(data)

      f.close
      
      fname
  end
  
  def cleanup_temp_file(filename)
    begin
      FileUtils.rm(filename, force: true)
    rescue
    end
  end
end