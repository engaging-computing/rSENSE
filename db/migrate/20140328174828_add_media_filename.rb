class AddMediaFilename < ActiveRecord::Migration
  def up
    add_column :media_objects, :file, :string
  end

  def down
    remove_column :media_objects, :file, :string
  end
end
