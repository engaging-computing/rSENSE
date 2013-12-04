require 'nokogiri'
require 'fileutils'
require 'roo'

class GpxParser
  def convert(filepath)

    doc = Nokogiri::XML(File.open(filepath)).remove_namespaces!()
    
    trkpts = doc.css("trkpt")
    
    csv = "" 
    headers = trkpts.first.attributes

    Rails.logger.info "-----BEGIN-----"
    Rails.logger.info trkpts.first

    #Grab attributes from the first trkpt for headers
    trkpts.first.attributes.each do |header|
      csv += header[0] + ","
    end

    #Grab contents from the first trkpt for headers
    elements = []
    trkpts.first.traverse do |node|
      if(node.children.count == 0)
        csv += node.parent.name + ","
        elements << node.parent.name
      end
    end
    csv = csv.chomp(",")
    csv += "\n"

    Rails.logger.info csv
    trkpts.each do |pt|
      line = ""

      #Grab headers out of attributes for each trkpt
      headers.each do |h|
        line += "#{pt.attribute(h[0])},"
      end

      #Grab contents out of each trkpt

      elements.each do |e|
        begin
          line += "#{pt.search(e).first.content},"
        rescue
          line += ","
        end
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