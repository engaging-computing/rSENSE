class FixMediaObjectsForProjects < ActiveRecord::Migration
  def up
    rename_column :media_objects, :experiment_id, :project_id
  end

  def down
    rename_column :media_objects, :project_id, :experiment_id
  end
end
