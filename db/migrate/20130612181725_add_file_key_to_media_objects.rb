class AddFileKeyToMediaObjects < ActiveRecord::Migration
  def change
    add_column :media_objects, :file_key, :String
  end
end
