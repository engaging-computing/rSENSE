class AddValidationKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :validation_key, :string
  end
end
