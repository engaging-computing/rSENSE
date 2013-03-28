class RemoveFileFromDataSets < ActiveRecord::Migration
  def up
    remove_column :data_sets, :file
  end

  def down
    add_column :data_sets, :file
  end
end
