class AddHiddenToEverything < ActiveRecord::Migration
  def change
    add_column :users, :hidden, :boolean, default: false
    add_column :data_sets, :hidden, :boolean, default: false
    add_column :visualizations, :hidden, :boolean, default: false
    add_column :media_objects, :hidden, :boolean, default: false
    add_column :projects, :hidden, :boolean, default: false
    add_column :tutorials, :hidden, :boolean, default: false
  end
end
