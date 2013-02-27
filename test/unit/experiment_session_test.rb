require 'test_helper'

class ExperimentSessionTest < ActiveSupport::TestCase
 
  # Creates a new experiment session and tests that the default fields are correctly set
  
  # Defines and initializes a new experiment session
  experiment_session = ExperimentSession.new
  
  # Passes if content is nil
  test "content is nil" do
    assert_nil( experiment_session.content, "Expected content is nil." )
  end
  
  # ---------------------------------------------------
  # Testing with fixtures
  
  test "sessions title" do
    assert_equal "Sample Title", experiment_sessions(:one).title
  end

  test "user_id" do
    assert_equal 1, experiment_sessions(:one).user_id
  end
  
  test "experiment_id" do
    assert_equal 1, experiment_sessions(:one).experiment_id
  end

  test " experiment content" do
    assert_nil experiment_sessions(:one).content, "Expected content is nil." 
  end
  
# test " experiment src" do
#    assert_nil experiment_sessions(:one).src, "Expected src is nil." 
# end

end
