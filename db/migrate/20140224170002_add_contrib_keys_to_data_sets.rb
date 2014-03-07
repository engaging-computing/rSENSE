 class AddContribKeysToDataSets < ActiveRecord::Migration
   def change
     add_column :data_sets, :key, :string
   end
 end
