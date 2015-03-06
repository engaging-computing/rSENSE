class RemoveWhitespaceFromRestrictions < ActiveRecord::Migration
  def up
    Field.find_each do |field|
      if field.restrictions.nil? or field.restrictions == ''
        field.restrictions = []
      end
      field.restrictions.map! do |restriction|
        restriction.strip!
        restriction
      end
    end
  end
end
