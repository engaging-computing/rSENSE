class FixDefaultsForFields < ActiveRecord::Migration
  def up
    change_column :fields, :unit, :text, default: ''
  end

  def down
    change_column :fields, :unit, :text, default: nil
  end
end
