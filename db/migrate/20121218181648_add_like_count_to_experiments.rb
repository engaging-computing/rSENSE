class AddLikeCountToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :like_count, :integer
  end
end
