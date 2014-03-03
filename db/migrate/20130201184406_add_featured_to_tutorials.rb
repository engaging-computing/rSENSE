class AddFeaturedToTutorials < ActiveRecord::Migration
  def change
    add_column :tutorials, :featured_number, :integer, default: nil
  end
end
