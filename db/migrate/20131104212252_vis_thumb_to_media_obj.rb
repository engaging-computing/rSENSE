class VisThumbToMediaObj < ActiveRecord::Migration
  def up
    add_column :visualizations, :thumb_id, :integer

    Visualization.all.each do |vi|
      tn_src = vi.read_attribute(:tn_src)
      next unless tn_src

      mo = MediaObject.new
      mo.visualization_id = vi.id
      mo.media_type = 'image'
      mo.name = 'image.png'
      mo.check_store!

      FileUtils.cp("#{Rails.root}/app/assets/images/noimage.png", mo.file_name)

      if tn_src =~ /amazonaws/
        # Get the thumbnail
        re = HTTParty.get(tn_src)
        print "."; STDOUT.flush

        if re.code == 200
          File.open(mo.file_name, "wb") do |ff|
            ff.write(re.body)
          end
      
          mo.add_tn
        end
      end

      mo.save!

      vi.thumb_id = mo.id

      vi.save!

      vi2 = Visualization.find(vi.id)
      raise Exception.new("WTF") unless vi2.thumb_id
    end

    puts "+"
  end

  def down
    remove_column :visualizations, :thumb_id 

    puts "Again, non-reversable migrations are awesome."
  end
end
