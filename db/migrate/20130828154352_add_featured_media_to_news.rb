class AddFeaturedMediaToNews < ActiveRecord::Migration
  def change
    add_column :news, :featured_media_id, :integer, :default => nil
  end
end
