class AddFormulaFields < ActiveRecord::Migration
  def up
    add_column(:fields, :refname, :string, default: '')
    add_column(:fields, :formula, :string, default: '')

    Field.find_each do |f|
      f.update_attribute(:refname, f.choose_refname)
    end
  end

  def down
    remove_column(:fields, :refname)
    remove_column(:fields, :formula)
  end
end
