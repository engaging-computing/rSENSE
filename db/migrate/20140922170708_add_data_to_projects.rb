class AddDataToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :data, :string
  end
end
