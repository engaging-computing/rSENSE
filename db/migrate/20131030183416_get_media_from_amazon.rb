class GetMediaFromAmazon < ActiveRecord::Migration
  def up
    add_column :media_objects, :store_key, :string

    MediaObject.all.each do |mo|
      mo.check_store!

      if mo.src && mo.src =~ /amazonaws/
        # The object
        re = HTTParty.get(mo.src)
        print "."; STDOUT.flush

        if re.code == 200
          File.open(mo.file_name, "wb") do |ff|
            ff.write(re.body)
          end
        end

        mo.src = mo.file_path
      end

      if mo.tn_src =~ /amazonaws/
        # The thumbnail
        re = HTTParty.get(mo.tn_src)
        print "."; STDOUT.flush

        if re.code == 200
          File.open(mo.tn_file_name, "wb") do |ff|
            ff.write(re.body)
          end
        end

        mo.tn_src = mo.tn_file_path
      end

      mo.save!
    end

    add_column :visualizations, :store_key, :string

    Visualization.all.each do |vi|
      vi.check_store!

      if vi.tn_src =~ /amazonaws/
        # Get the thumbnail
        re = HTTParty.get(vi.tn_src)
        print "."; STDOUT.flush

        if re.code == 200
          File.open(vi.tn_file_name, "wb") do |ff|
            ff.write(re.body)
          end
        end

        vi.tn_src = vi.tn_file_path
      end

      vi.save!
    end
  end

  def down
    remove_column :media_objects, :store_key
    remove_column :visualizations, :store_key
  end
end
