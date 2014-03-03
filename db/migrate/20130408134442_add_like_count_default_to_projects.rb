class AddLikeCountDefaultToProjects < ActiveRecord::Migration
  def up
    change_column :projects, :like_count, :integer,  default: 0
  end

  def down
    change_column :projects, :like_count, :integer,  default: nil
  end
end
