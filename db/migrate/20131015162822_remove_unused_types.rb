class RemoveUnusedTypes < ActiveRecord::Migration
  def up
    drop_table :memberships
    drop_table :groups
  end

  def down
  end
end
