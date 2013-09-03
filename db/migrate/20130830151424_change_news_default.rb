class ChangeNewsDefault < ActiveRecord::Migration
  def up
    change_column :news, :hidden, :boolean, :default => true
  end

  def down
  end
end
