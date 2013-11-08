class GetMediaFromAmazon < ActiveRecord::Migration
  def up
    # First, download all the media.

    MediaObject.all.each do |mo|
      mo.check_store!

      src = mo.read_attribute(:src)

      if src && src =~ /amazonaws/ && !File.exists?(mo.file_name)
        # The object
        re = HTTParty.get(src)
        print "."; STDOUT.flush

        if re.code == 200
          File.open(mo.file_name, "wb") do |ff|
            ff.write(re.body)
          end
        
          mo.add_tn
        end
      end

      mo.save!
    end

    puts " ="
  end

  def down
    puts "This is a lie. Nothing is getting reversed."
  end
end
