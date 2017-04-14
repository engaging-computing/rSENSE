class AddCountToDataSets < ActiveRecord::Migration
  def up
    add_column :data_sets, :count, :integer, default: 0

    say 'Setting count of each data set - This could take a while!'
    DataSet.find_each do |d|
      d.count = d.data.count
      d.save
    end
  end

  def down
    remove_column :data_sets, :count, :integer
  end
end
