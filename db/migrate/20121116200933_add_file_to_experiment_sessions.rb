class AddFileToExperimentSessions < ActiveRecord::Migration
  def change
    add_column :experiment_sessions, :file, :string
  end
end
