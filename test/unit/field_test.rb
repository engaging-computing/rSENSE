require 'test_helper'

class FieldTest < ActiveSupport::TestCase

  # Tests that all default fields of a new field are correctly set
  
  # Declares a new field
    def setup
      @field = Field.new
    end
    
  # Passes if unit is an empty string
    test "unit is an empty string" do
      assert_equal "", @field.unit, "Expected field unit is not an empty string."
    end
  
end
