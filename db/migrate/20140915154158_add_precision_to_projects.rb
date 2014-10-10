class AddPrecisionToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :precision, :integer, default: 4
  end
end
