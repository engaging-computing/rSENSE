require 'test_helper'

class DataSetTest < ActiveSupport::TestCase

  # Tests that all default fields of a new data set are correctly set
  
  # Declares a new data set
  def setup
    @data_set = DataSet.new
  end
  
  # Passes if content is nil
  test "content is nil" do
    assert_default_nil( @data_set, @data_set.content )
  end
  
  # ---------------------------------------------------
  # Testing with fixtures
  
  test "sessions title" do
    assert_equal "Sample Title", data_sets(:one).title
  end

  test "user_id" do
    assert_equal 1, data_sets(:one).user_id
  end
  
  test "project_id" do
    assert_equal 1, data_sets(:one).project_id
  end

  test "project content" do
    assert_nil data_sets(:one).content, "Expected content is not nil." 
  end
  
end