class ChangeTutorialDefaults < ActiveRecord::Migration
  def change
    change_column :tutorials, :hidden, :boolean, :default => true
  end
end
