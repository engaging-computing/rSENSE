class AddCuratedTimeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :curated_at, :timestamp, :default => nil
  end
end
