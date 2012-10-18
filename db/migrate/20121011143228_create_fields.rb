class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name
      t.integer :field_type
      t.string :unit
      t.integer :experiment_id

      t.timestamps
    end
  end
end
