class AddFormulaFields < ActiveRecord::Migration
  def up
    # create a table for formula fields
    create_table :formula_fields do |t|
      t.string 'name'
      t.integer 'field_type'
      t.text 'unit', limit: 255, default: ''
      t.integer 'project_id'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.integer 'index'
      t.string 'refname', default: ''
      t.string 'formula', default: ''
    end

    # add a refname attribute to existing fields
    add_column :fields, :refname, :string, default: ''
    Field.find_each do |f|
      f.update_attribute :refname, f.choose_refname
    end
  end

  def down
    # remove the formula fields table
    drop_table :formula_fields

    # remove the refname attribute
    remove_column :fields, :refname
  end
end
