class AddNewsToUser < ActiveRecord::Migration
  def change
    add_column :users, :news_id, :integer
  end
end
