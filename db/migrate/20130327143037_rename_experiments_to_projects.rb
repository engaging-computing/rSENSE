class RenameExperimentsToProjects < ActiveRecord::Migration
  def up
    rename_table :experiments, :projects
  end

  def down
    rename_table :projects, :experiments
  end
end
