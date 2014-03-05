class AddCurateFlagToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :curated, :boolean, default: false
  end
end
