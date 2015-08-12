class AddIndexToFields < ActiveRecord::Migration
  def up
    add_column :fields, :index, :integer
    Project.find_each do |p|
      p.fields.each_with_index do |f, index|
        f.update_attribute(:index, index)
      end
    end
  end

  def down
    remove_column :fields, :index
  end
end
