class CreateMediaObjects < ActiveRecord::Migration
  def change
    create_table :media_objects do |t|
      t.integer :experiment_id
      t.string :media_type
      t.string :name
      t.integer :session_id
      t.integer :user_id

      t.timestamps
    end
  end
end
