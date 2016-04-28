require 'test_helper'

class TutorialTest < ActiveSupport::TestCase
  # Tests that all default fields of a new tutorial are correctly set

  # Declares a new tutorial
  def setup
    @tutorial = Tutorial.new
  end

  # Passes if category is nil
  test 'category is nil' do
    assert_default_nil(@tutorial, @tutorial.category)
  end
end
