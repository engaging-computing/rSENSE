class FixDecimalWierdness < ActiveRecord::Migration
  def up
    change_column :tutorials, :user_id, :integer
    change_column :media_objects, :visualization_id, :integer
  end
  
  def down
    change_column :tutorials, :user_id, :decimal
    change_column :media_objects, :visualization_id, :decimal
  end
end
