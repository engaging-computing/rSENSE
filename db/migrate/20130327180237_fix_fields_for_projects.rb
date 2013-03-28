class FixFieldsForProjects < ActiveRecord::Migration
  def up
    rename_column :fields, :experiment_id, :project_id
  end

  def down
    rename_column :fields, :project_id, :experiment_id
  end
end
