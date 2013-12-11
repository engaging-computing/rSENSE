class AddRestrictionsToFields < ActiveRecord::Migration
  def change
    add_column :fields, :restrictions, :text, :default => nil
  end
end
