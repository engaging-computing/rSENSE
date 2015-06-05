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
end
