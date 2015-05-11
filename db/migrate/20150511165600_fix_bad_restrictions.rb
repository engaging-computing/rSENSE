class FixBadRestrictions < ActiveRecord::Migration
  def up
    Field.find_each do |field|
      if field.restrictions.nil? or field.restrictions == ''
        field.restrictions = []
      end
    end
  end
end
