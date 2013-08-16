class AddFeaturedMediaIdToTutorials < ActiveRecord::Migration
  def change
    add_column :tutorials, :featured_media_id, :integer, :default => nil
  end
end
