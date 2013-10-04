class KillMongo < ActiveRecord::Migration
  def up
    add_column :data_sets, :data, :text, default: '[]', null: false
  end

  def down
    remove_column :data_sets, :data
  end
end
