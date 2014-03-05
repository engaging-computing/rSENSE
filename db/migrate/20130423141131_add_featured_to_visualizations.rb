class AddFeaturedToVisualizations < ActiveRecord::Migration
  def change
    add_column :visualizations, :featured, :boolean, default: false
    add_column :visualizations, :featured_at, :timestamp, default: nil
  end
end
