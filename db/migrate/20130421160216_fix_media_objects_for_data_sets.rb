class FixMediaObjectsForDataSets < ActiveRecord::Migration
  def up
    rename_column :media_objects, :session_id, :data_set_id
  end

  def down
    rename_column :media_objects, :data_set_id, :session_id
  end
end
