class AddFeaturedAtToTutorial < ActiveRecord::Migration
  def change
    add_column :tutorials, :featured_at, :timestamp, default: nil
  end
end
