class RemoveContentFromDataSets < ActiveRecord::Migration
  def up
    remove_column :data_sets, :content
  end

  def down
    add_column :data_sets, :content, :text, default: nil
  end
end
