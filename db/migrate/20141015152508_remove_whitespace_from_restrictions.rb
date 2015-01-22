class RemoveWhitespaceFromRestrictions < ActiveRecord::Migration
  def up
    Field.find_each do |field|
      unless field.restrictions.nil?
        field.restrictions.map! do |restriction|
          restriction.strip!
          restriction
        end
      end
    end
  end
end
