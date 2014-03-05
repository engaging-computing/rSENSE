class RemoveUnusedTypes < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.tables.include?('memberships')
      drop_table :memberships
    end
    if ActiveRecord::Base.connection.tables.include?('groups')
      drop_table :groups
    end
  end

  def down
  end
end
