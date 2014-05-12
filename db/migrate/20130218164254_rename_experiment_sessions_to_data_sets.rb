class RenameExperimentSessionsToDataSets < ActiveRecord::Migration
  def up
    rename_table :experiment_sessions, :data_sets
  end

  def down
    rename_table :data_sets, :experiment_sessions
  end
end
