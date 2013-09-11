class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string :title
      t.text :content
      t.text :description
      t.boolean :hidden, :default => false
      t.timestamps
    end
  end
end
