class ChangeTutorialFeaturedToBoolean < ActiveRecord::Migration
  def change
    add_column :tutorials, :featured, :boolean, default: false
    remove_column :tutorials, :featured_number, :integer
  end
end
