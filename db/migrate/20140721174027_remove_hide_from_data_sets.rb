class RemoveHideFromDataSets < ActiveRecord::Migration
  def change
    remove_column :data_sets, :hidden
  end
end
