class FixVizForProjects < ActiveRecord::Migration
  def up
    rename_column :visualizations, :experiment_id, :project_id
  end

  def down
    rename_column :visualizations, :project_id, :experiment_id
  end
end
