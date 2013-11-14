require 'nokogiri'
require 'fileutils'
require 'roo'

class GpxParser
  def convert(filepath)

    doc = Nokogiri::XML(File.open(filepath))
    
    trkpts = doc.css("trkpt")
    
    csv = "Timestamp,Name,Latitude,Longitude\n"
    
    trkpts.each do |pt|
      csv += "#{pt.search('time').first.content},"
      csv += "#{pt.search('name').first.content},"
      csv += "#{pt.attribute('lat')},"
      csv += "#{pt.attribute('lon')}\n"
    end
    
    filename = write_temp_file(csv)
    
    roo = Roo::CSV.new(filename)

#     cleanup_temp_file(filename)

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