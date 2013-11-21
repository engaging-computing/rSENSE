class CreateViewCounts < ActiveRecord::Migration
  def change
    create_table :view_counts do |t|
      t.integer :project_id, null: false
      t.integer :count, null: false, default: 0

      t.timestamps
    end
  end
end
