class AddKmlToProject < ActiveRecord::Migration
  def change
    add_column :projects, :kml_metadata, :text, default: nil
  end
end
