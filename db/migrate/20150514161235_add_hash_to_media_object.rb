class AddHashToMediaObject < ActiveRecord::Migration
  def up
    add_column :media_objects, :md5, :string
    MediaObject.find_each do |mo|
      mo.md5 = Digest::MD5.file(mo.file_name).hexdigest
      mo.save
    end
  end

  def down
    remove_column :media_objects, :md5
  end
end
