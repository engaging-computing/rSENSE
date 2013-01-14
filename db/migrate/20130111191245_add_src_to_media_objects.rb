class AddSrcToMediaObjects < ActiveRecord::Migration
  def change
    add_column :media_objects, :src, :string
  end
end
