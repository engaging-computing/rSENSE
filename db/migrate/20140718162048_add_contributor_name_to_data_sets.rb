class AddContributorNameToDataSets < ActiveRecord::Migration
  def change
    add_column :data_sets, :contributor_name, :string, default: nil
  end
end
