class RemoveLikeCountFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :like_count, :integer
  end
end
