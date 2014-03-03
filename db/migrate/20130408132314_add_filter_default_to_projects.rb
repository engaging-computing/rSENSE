class AddFilterDefaultToProjects < ActiveRecord::Migration
  def up
    change_column :projects, :filter, :text,  default: ''
  end

  def down
    change_column :projects, :filter, :text,  default: nil
  end
end
