class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
      t.text :content
      t.string :title

      t.timestamps
    end
  end
end
