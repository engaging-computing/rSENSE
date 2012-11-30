class AddClonedFromToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :cloned_from, :integer
  end
end
