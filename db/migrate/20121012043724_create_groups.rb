class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :owner_id
      t.string :default_password
      t.string :content

      t.timestamps
    end
  end
end
