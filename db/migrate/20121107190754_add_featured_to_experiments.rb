class AddFeaturedToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :featured, :boolean, default: false
  end
end
