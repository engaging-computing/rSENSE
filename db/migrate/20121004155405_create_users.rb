class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :firstname
      t.string :lastname
      t.string :username
      t.string :email
      t.text :content
      t.integer :group_id
      t.boolean :validated
      t.string :password_digest

      t.timestamps
    end
  end
end
