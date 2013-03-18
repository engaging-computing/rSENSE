require 'test_helper'

class ExperimentTest < ActiveSupport::TestCase

  # Creates a new experiment and tests that the default fields are correctly set

  # Defines and initializes a new experiment
  experiment = Experiment.new
  
  # Passes if content is nil
  test "content is nil" do
    assert_nil( experiment.content, "Expected content is nil." )
  end
  
  # Passes if cloned_from is nil
  test "cloned_from is nil" do
    assert_nil( experiment.cloned_from, "Expected cloned_from is nil." )
  end
  
  # Passes if featured if false
  test "featured is false" do
    assert_equal( false, experiment.featured, "Expected featured is false." )
  end
  
  # Passes if is_tempalte is false
  test "is_template is false" do
    assert_equal( false, experiment.is_template, "Expected is_template is false." )
  end   
  
  # ---------------------------------------------------
  # Testing with fixtures
  
  test "experiment title" do
    assert_equal "Sample Test", experiments(:one).title
  end
  
  test "experiment user_id" do
    assert_equal 1, experiments(:one).user_id
  end
  
  test "experiment content" do
    assert_equal "Sample Content", experiments(:one).content
  end
  
end
