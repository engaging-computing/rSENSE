class AddFilterToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :filter, :string
  end
end
