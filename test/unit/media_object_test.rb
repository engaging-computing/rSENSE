require 'test_helper'

class MediaObjectTest < ActiveSupport::TestCase

  # Tests that all default fields of a new media object are correctly set
  
  # Declares a new media object
  def setup
    @media_object = MediaObject.new
  end
  
  # Passes if project_id is nil
  test "project_id is nil" do
    assert_default_nil( @media_object, @media_object.project_id )
  end
  
  # Passes if user_id is nil
  test "user_id is nil" do
    assert_default_nil( @media_object, @media_object.user_id )
  end

  # Passes if tutorial_id is nil
  test "tutorial_id is nil" do
    assert_default_nil( @media_object, @media_object.tutorial_id )
  end
  
  # Passes if data_set_id is nil
  test "data_set_id is nil" do
    assert_default_nil( @media_object, @media_object.data_set_id )
  end

  # Passes if visualization_id is nil
  test "visualization_id is nil" do
    assert_default_nil( @media_object, @media_object.visualization_id )
  end
  
  # Passes if hidden is false
  test "hidden is false" do
    assert_default_false( @media_object, @media_object.hidden )
  end
  
end