class AddTemplateToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :is_template, :boolean, default: false
  end
end
