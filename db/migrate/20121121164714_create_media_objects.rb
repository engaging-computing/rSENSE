class CreateMediaObjects < ActiveRecord::Migration
  def change
    create_table :media_objects do |t|
      t.integer :media_type
      t.string :name
      t.text :src
      t.integer :user_id
      t.integer :experiment_id
      t.integer :session_id

      t.timestamps
    end
  end
end
