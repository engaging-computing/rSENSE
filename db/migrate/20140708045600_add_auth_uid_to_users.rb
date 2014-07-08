class AddAuthUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :auth_uid, :string
  end
end
