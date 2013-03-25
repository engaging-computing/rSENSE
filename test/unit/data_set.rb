require 'test_helper'

class DataSetTest < ActiveSupport::TestCase

  # Creates a new data set and tests that the default fields are correctly set
  
  # Defines and initializes a new data set
  data_set = DataSet.new
  
  # Passes if content is nil
  test "content is nil" do
    assert_nil( data_set.content, "Expected content is nil." )
  end
  


  # ---------------------------------------------------
  # Testing with fixtures
  
  test "sessions title" do
    assert_equal "Sample Title", data_sets(:one).title
  end

  test "user_id" do
    assert_equal 1, data_sets(:one).user_id
  end
  
  test "experiment_id" do
    assert_equal 1, data_sets(:one).experiment_id
  end

  test " experiment content" do
    assert_nil data_sets(:one).content, "Expected content is nil." 
  end
  
end
