class FixBadRestrictions < ActiveRecord::Migration
  def up
    change_column :fields, :restrictions, :text, default: '[]'
    Field.find_each do |field|
      if field.restrictions.nil? or field.restrictions == ''
        field.restrictions = []
      end
    end
  end

  def down
    change_column :fields, :restrictions, :text, default: nil
  end
end
