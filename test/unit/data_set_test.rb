require 'test_helper'

class DataSetTest < ActiveSupport::TestCase
  # Tests that all default fields of a new data set are correctly set

  # Declares a new data set
  def setup
    @data_set = DataSet.new
  end

  # ---------------------------------------------------
  # Testing with fixtures

  test 'data set title' do
    assert_equal 'Sample Title', data_sets(:one).title
  end

  test 'user_id' do
    assert_equal users(:kate).id, data_sets(:one).user_id
  end

  test 'project_id' do
    assert_equal projects(:one).id, data_sets(:one).project_id
  end
end
