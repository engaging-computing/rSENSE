class KillMongo < ActiveRecord::Migration
  def up
    add_column :data_sets, :data, :text, default: '[]', null: false

    DataSet.all.each do |ds|
      ds.data = MongoData.find_by_data_set_id(ds.id).data
      ds.save!
    end
  end

  def down
    remove_column :data_sets, :data
  end
end
