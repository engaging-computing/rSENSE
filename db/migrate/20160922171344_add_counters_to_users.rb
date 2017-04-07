class AddCountersToUsers < ActiveRecord::Migration
  def up
    add_column :users, :projects_count, :integer, default: 0
    add_column :users, :data_sets_count, :integer, default: 0
    add_column :users, :visualizations_count, :integer, default: 0

    User.all.each do |user|
      User.reset_counters(user.id, :projects)
      User.reset_counters(user.id, :data_sets)
      User.reset_counters(user.id, :visualizations)
    end
  end

  def down
    remove_column :users, :projects_count, :integer
    remove_column :users, :data_sets_count, :integer
    remove_column :users, :visualizations_count, :integer
  end
end
