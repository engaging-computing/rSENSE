class KillMongo < ActiveRecord::Migration
  def up
    add_column :data_sets, :data, :text, default: '[]', null: false

    DataSet.all.each do |ds|
      md = MongoData.find_by_data_set_id(ds.id)
      if md
        ds.data = md.data
        ds.save!
      end
    end
  end

  def down
    remove_column :data_sets, :data
  end
end
