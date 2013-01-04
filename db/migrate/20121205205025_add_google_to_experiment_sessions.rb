class AddGoogleToExperimentSessions < ActiveRecord::Migration
  def change
    add_column :experiment_sessions, :googleDoc, :string
  end
end
