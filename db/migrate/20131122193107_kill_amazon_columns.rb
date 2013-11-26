class KillAmazonColumns < ActiveRecord::Migration
  def change
    remove_column :media_objects, :src, :string
    remove_column :media_objects, :file_key, :string
    remove_column :media_objects, :tn_src, :string
    remove_column :media_objects, :tn_file_key, :string

    remove_column :visualizations, :tn_src, :string
    remove_column :visualizations, :tn_file_key, :string
  end
end
