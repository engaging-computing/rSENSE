class AddFormulaFields < ActiveRecord::Migration
  def up
    add_column(:fields, :refname, :string, default: '')
    add_column(:fields, :formula, :string, default: '')

    Project.find_each do |p|
      valid_names = []
      p.fields.find_each do |f|
        new_name = f.name.gsub(/[^0-9A-Za-z]/, '').camelize :lower
        test_name = new_name
        name_count = 1

        while valid_names.include? test_name
          test_name = "#{new_name}#{name_count}"
          name_count += 1
        end

        valid_names << test_name
        f.update_attribute(:refname, test_name)
      end
    end
  end

  def down
    remove_column(:fields, :refname)
    remove_column(:fields, :formula)
  end
end
