class RenameVisualisationsToVisualizations < ActiveRecord::Migration
  def up
    rename_table :visualisations, :visualizations
  end

  def down
    rename_table :visualizations, :visualisations
  end
end
