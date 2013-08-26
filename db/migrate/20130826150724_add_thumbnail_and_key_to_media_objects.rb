class AddThumbnailAndKeyToMediaObjects < ActiveRecord::Migration
  def change
    add_column :media_objects, :tn_src, :string, :default => ""
    add_column :media_objects, :tn_file_key, :string, :default => ""
  end
end
