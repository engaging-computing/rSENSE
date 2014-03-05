class AddUserLoginTracking < ActiveRecord::Migration
  def up
    add_column :users, :last_login, :timestamp, default: '2013-08-16 12:00:00'
  end

  def down
  end
end
