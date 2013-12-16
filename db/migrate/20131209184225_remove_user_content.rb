class RemoveUserContent < ActiveRecord::Migration
  def change
    remove_column :users, :content, :text
  end
end
