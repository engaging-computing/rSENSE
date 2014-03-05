class AddFeaturedTimeToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :featured_at, :timestamp, default: nil
  end
end
