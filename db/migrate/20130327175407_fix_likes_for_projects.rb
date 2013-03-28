class FixLikesForProjects < ActiveRecord::Migration
  def up
    rename_column :likes, :experiment_id, :project_id
  end

  def down
    rename_column :likes, :project_id, :experiment_id
  end
end
