class AddGlobalsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :globals, :string
  end
end
