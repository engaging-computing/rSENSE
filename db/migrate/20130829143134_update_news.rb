class UpdateNews < ActiveRecord::Migration
  def up
    change_column :news, :description, :text, :default => nil
    rename_column :news, :description, :summary
  end

  def down
  end
end
