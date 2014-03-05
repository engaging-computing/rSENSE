class AddDefaultVisToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :default_vis, :text, default: nil
  end
end
