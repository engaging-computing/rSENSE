class CreateVisualisations < ActiveRecord::Migration
  def change
    create_table :visualisations do |t|
      t.string :title
      t.integer :user_id
      t.integer :experiment_id
      t.text :content
      t.text :data
      t.text :globals

      t.timestamps
    end
  end
end
