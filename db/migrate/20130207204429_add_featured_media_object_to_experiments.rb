class AddFeaturedMediaObjectToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :featured_media_id, :integer, default: nil
  end
end
