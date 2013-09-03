class AddNewsToMedia < ActiveRecord::Migration
  def change
    add_column :media_objects, :news_id, :integer
  end
end
