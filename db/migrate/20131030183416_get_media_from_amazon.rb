class GetMediaFromAmazon < ActiveRecord::Migration
  def up
    add_column :media_objects, :store_key, :string

    MediaObject.all.each do |mo|
      mo.check_store!

      src = mo.read_attribute(:src)

      if src && src =~ /amazonaws/
        # The object
        re = HTTParty.get(src)
        print "."; STDOUT.flush

        if re.code == 200
          File.open(mo.file_name, "wb") do |ff|
            ff.write(re.body)
          end
        end
      end

      tn_src = mo.read_attribute(:tn_src)

      if tn_src && tn_src =~ /amazonaws/
        # The thumbnail
        re = HTTParty.get(tn_src)
        print "."; STDOUT.flush

        if re.code == 200
          File.open(mo.tn_file_name, "wb") do |ff|
            ff.write(re.body)
          end
        end
      end

      mo.save!
    end

    add_column :visualizations, :store_key, :string

    Visualization.all.each do |vi|
      vi.check_store!

      tn_src = vi.read_attribute(:tn_src)

      if tn_src && tn_src =~ /amazonaws/
        # Get the thumbnail
        re = HTTParty.get(tn_src)
        print "."; STDOUT.flush

        if re.code == 200
          File.open(vi.tn_file_name, "wb") do |ff|
            ff.write(re.body)
          end
        end
      end

      vi.save!
    end
  end

  def down
    remove_column :media_objects, :store_key
    remove_column :visualizations, :store_key
  end
end
