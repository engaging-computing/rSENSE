class AddAuthUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_username, :string
  end
end
