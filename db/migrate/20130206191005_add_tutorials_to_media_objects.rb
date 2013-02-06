class AddTutorialsToMediaObjects < ActiveRecord::Migration
  def change
    add_column :media_objects, :tutorial_id, :integer
  end
end
