class AddMediaKeys < ActiveRecord::Migration
  def up
    add_column :media_objects, :store_key, :string
  end

  def down
    remove_column :media_objects, :store_key
  end
end
