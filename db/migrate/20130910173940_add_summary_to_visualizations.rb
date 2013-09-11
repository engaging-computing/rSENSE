class AddSummaryToVisualizations < ActiveRecord::Migration
  def change
    add_column :visualizations, :summary, :text, :default => nil
  end
end
