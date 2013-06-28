require 'test_helper'

class TutorialTest < ActiveSupport::TestCase

  # Tests that all default fields of a new tutorial are correctly set

  # Declares a new tutorial
  def setup
    @tutorial = Tutorial.new
  end
  
  # Passes if content is nil
  test "content is nil" do
    assert_default_nil( @tutorial, @tutorial.content )
  end
  
  # Passes if hidden is false
  test "hidden is false" do
    assert_default_false( @tutorial, @tutorial.hidden )
  end
  
end