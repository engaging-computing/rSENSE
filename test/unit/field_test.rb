require 'test_helper'

class FieldTest < ActiveSupport::TestCase
  # Tests that all default fields of a new field are correctly set

  # Declares a new field
  def setup
    @field = Field.new

    @field2 = Field.new
    @field2.project_id = projects(:one).id
    @field2.name = 'Field 1 ABC'
    @field2.field_type = 2
    @field2.index = 4

    # id of the formula fields test project
    @pid = projects(:formula_fields_test).id
  end

  # Passes if the non-recursive hash contains the right values
  test 'non-recursive hash is correct' do
    # stub out an id and refname
    @field2.id = 5000
    @field2.refname = 'Field1Abc'

    # convert the formula field to a hash and check its values
    h = @field2.to_hash recurse: false
    keys = [:id, :name, :type, :unit, :refname, :restrictions, :index].all? { |x| h.key? x }
    assert keys, 'Hash is missing one or more keys'
    assert h[:id] == 5000, 'ID in hash is not a number'
    assert h[:name] == 'Field 1 ABC', 'Wrong name in hash'
    assert h[:type] == 2, 'Wrong field type in hash'
    assert h[:unit] == '', 'Wrong unit in hash'
    assert h[:refname] == 'Field1Abc', 'Wrong refname in hash'
    assert h[:restrictions] == [], 'Wrong restrictions in hash'
    assert h[:index] == 4, 'Wrong index in hash'
  end

  # passes if the recursive hash contains the right values
  test 'recursive hash is correct' do
    # convert the formula field to a hash and check its values
    h = @field2.to_hash
    keys = [:id, :name, :type, :unit, :refname, :restrictions, :index, :project].all? { |x| h.key? x }
    assert keys, 'Hash is missing one or more keys'
    assert h[:project][:id] == @field2.project_id
    assert h[:project][:name] == 'Measuring Things'
  end

  # Passes if unit is an empty string
  test 'unit is an empty string' do
    assert_equal '', @field.unit, 'Expected field unit is not an empty string.'
  end

  # Passes if restrictions is an empty array
  test 'restrictions are an empty array' do
    assert_equal [], @field.restrictions, 'Expected field restrictions to be an empty array'
  end

  # Passes if field fails validation
  test 'fail with bad restrictions' do
    assert @field2.valid?, 'Field should initially be valid'
    @field2.restrictions = 4
    assert !@field2.valid?, 'Result should not be valid'
  end

  test 'fail with bad array restrictions' do
    assert @field2.valid?, 'Field should initially be valid'
    @field2.restrictions = [:some_label, [1, 2, 3]]
    assert !@field2.valid?, 'Result should not be valid'
  end

  # Passes if field passes validation
  test 'pass with good restrictions' do
    assert @field2.valid?, 'Field should initially be valid'
    @field2.restrictions = 'a,b,c'
    assert @field2.valid?, 'Result should be valid'
  end

  test 'pass with good array restrictions' do
    assert @field2.valid?, 'Field should initially be valid'
    @field2.restrictions = ['a', 'b', 'c']
    assert @field2.valid?, 'Result should be valid'
  end

  # Try to get a good default name when only the first default name exists
  test 'next name for timestamps' do
    name = Field.get_next_name(projects(:next_name_test), 1)
    assert name == 'Timestamp_2', "Name should have been Timestamp_2, not #{name}"
  end

  # Try to get a good default name with a gap and formula fields for numbers
  test 'next name for numbers' do
    name = Field.get_next_name(projects(:next_name_test), 2)
    assert name == 'Number_7', "Name should have been Number_7, not #{name}"
  end

  # Try to get a good default name with a gap and formula fields for text
  test 'next name for text' do
    name = Field.get_next_name(projects(:next_name_test), 3)
    assert name == 'Text_7', "Name should have been Text_7, not #{name}"
  end

  # Try to get a good default next name when no default names exist
  test 'next name for latitude' do
    name = Field.get_next_name(projects(:next_name_test), 4)
    assert name == 'Latitude', "Name should have been Latitude, not #{name}"
  end

  # Try to get a good default next name with gaps between default names
  test 'next name for longitude' do
    name = Field.get_next_name(projects(:next_name_test), 5)
    assert name == 'Longitude_101', "Name should have been Longitude_101, not #{name}"
  end

  # Try to choose an appropriate refname with no collisions
  test 'get easy refname' do
    f = Field.new
    f.project_id = @pid
    f.name = 'word Word ++ Word'
    f.choose_refname
    assert_equal 'WordWordWord', f.refname
  end

  # Test out refname choosing with goofy casing
  test 'get tricky refname' do
    f = Field.new
    f.project_id = @pid
    f.name = 'ABC DEF GHI'
    f.choose_refname
    assert_equal 'AbcDefGhi', f.refname
  end

  # Try to choose an appropriate refname with a field name collision
  test 'get refname with field collision' do
    f = Field.new
    f.project_id = @pid
    f.name = 'N-F-2'
    f.choose_refname
    assert_equal 'NF21', f.refname
  end

  # Try to choose an appropriate refname with a formula field name collision
  test 'get refname with formula field collision' do
    f = Field.new
    f.project_id = @pid
    f.name = 'F-F-2'
    f.choose_refname
    assert_equal 'FF21', f.refname
  end

  # Try setting the field type to all of the possible values
  test 'set field type to something valid' do
    assert @field2.valid?, 'Field should be initially valid'
    @field2.field_type = 1
    assert @field2.valid?, 'Field should still be valid'
    @field2.field_type = 2
    assert @field2.valid?, 'Field should still be valid'
    @field2.field_type = 3
    assert @field2.valid?, 'Field should still be valid'
    @field2.field_type = 4
    assert @field2.valid?, 'Field should still be valid'
    @field2.field_type = 5
    assert @field2.valid?, 'Field should still be valid'
  end

  # Try setting the field type to some of the invalid values
  test 'set field type to something invalid' do
    assert @field2.valid?, 'Field should be initially valid'
    @field2.field_type = -1
    assert !@field2.valid?, 'Field should not be valid'
    @field2.field_type = 100
    assert !@field2.valid?, 'Field should not be valid'
    @field2.field_type = :a
    assert !@field2.valid?, 'Field should not be valid'
  end

  # Make sure that we're requiring a valid, existing project for each formula field
  test 'require valid project id' do
    assert @field2.valid?, 'Formula field should initially be valid'
    @field2.project_id = 'a tiny man trying to make his way in a world for much larger people'
    assert !@field2.valid?, 'Result should not be valid'
    errs = @field2.errors.full_messages
    assert errs.length == 1, 'Should only have one validation error'
    assert errs[0] == 'Project not found', 'Wrong error message'
  end

  # Passes if the field name is unique and considered valid
  test 'field name is unique' do
    @field2.project_id = @pid
    assert @field2.valid?, 'Field should initially be valid'
    @field2.name = 'A unique name'
    assert @field2.valid?, 'Result should be valid'
  end

  # Passes if the field name is not unique amongst formula fields
  test 'fail with non-unique formula field name' do
    @field2.project_id = @pid
    assert @field2.valid?, 'Field should initially be valid'
    @field2.name = 'FF1'
    assert !@field2.valid?, 'Result should not be valid'
    errs = @field2.errors.full_messages
    assert errs.length == 1, 'Should only have one validation error'
    assert errs[0] == 'FF1 has the same name as another formula field', 'Wrong error message'
  end

  # Passes if the field name is not unique amongst other fields
  test 'fail with non-unique field name' do
    @field2.project_id = @pid
    assert @field2.valid?, 'Formula field should initially be valid'
    @field2.name = 'No Formula 1'
    assert !@field2.valid?, 'Result should not be valid'
    errs = @field2.errors.full_messages
    assert errs.length == 1, 'Should only have one validation error'
    assert errs[0] == 'Name has already been taken', 'Wrong error message'
  end
end
