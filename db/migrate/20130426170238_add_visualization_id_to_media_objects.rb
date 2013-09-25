class AddVisualizationIdToMediaObjects < ActiveRecord::Migration
  def change
    add_column :media_objects, :visualization_id, :integer
  end
end
