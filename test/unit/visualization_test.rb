require 'test_helper'

class VisualizationTest < ActiveSupport::TestCase

  # Tests that all default fields of a new visualization are correctly set
  
  # Declares a new visualization
  def setup
    @visualization = Visualization.new
  end
  
  # Passes if hidden is false
  test "hidden is false" do
    assert_default_false( @visualization, @visualization.hidden )
  end
  
  # Passes if content is nil
  test "content is nil" do
    assert_default_nil( @visualization, @visualization.content )
  end
  
end
