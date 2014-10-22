class RemoveWhitespaceFromRestrictions < ActiveRecord::Migration
  def up
    Field.find_each do |field|
      if not field.restrictions.nil?
        field.restrictions.map! do |restriction|
          restriction.strip!
          restriction
        end
      end
    end
  end

  def down
  end
end
