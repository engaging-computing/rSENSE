class AddDefaultVisToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :default_vis, :text, :default => nil
  end
  
  def down
    
  end
end
