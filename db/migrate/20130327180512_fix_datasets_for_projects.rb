class FixDatasetsForProjects < ActiveRecord::Migration
  def up
    rename_column :data_sets, :experiment_id, :project_id
  end

  def down
    rename_column :data_sets, :project_id, :experiment_id
  end
end
