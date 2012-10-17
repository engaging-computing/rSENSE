class CreateExperimentSessions < ActiveRecord::Migration
  def change
    create_table :experiment_sessions do |t|
      t.string :title
      t.text :content
      t.integer :user_id
      t.integer :experiment_id

      t.timestamps
    end
  end
end
