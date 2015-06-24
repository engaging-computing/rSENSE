class AddHashToMediaObject < ActiveRecord::Migration
  def up
    add_column :media_objects, :md5, :string

    MediaObject.find_each do |mo|
      if File.exist? mo.file_name
        mo.md5 = Digest::MD5.file(mo.file_name).hexdigest
      end
      mo.save!
    end
  end

  def down
    remove_column :media_objects, :md5
  end
end
