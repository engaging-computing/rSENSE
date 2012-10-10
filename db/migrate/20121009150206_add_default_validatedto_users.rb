class AddDefaultValidatedtoUsers < ActiveRecord::Migration
  def up
    change_column :users, :validated, :boolean, default: false
  end

  def down
    change_column :users, :validated, :boolean, default: nil
  end
end
