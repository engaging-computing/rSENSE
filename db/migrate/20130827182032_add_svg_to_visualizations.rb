class AddSvgToVisualizations < ActiveRecord::Migration
  def change
    add_column :visualizations, :tn_src, :string, :default => nil
    add_column :visualizations, :tn_file_key, :string, :default => nil
  end
end
