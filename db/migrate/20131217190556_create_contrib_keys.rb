class CreateContribKeys < ActiveRecord::Migration
  def change
    create_table :contrib_keys do |t|
      t.string :name, null: false
      t.string :key, null: false
      t.integer :project_id, null: false
      t.timestamps
    end
  end
end
