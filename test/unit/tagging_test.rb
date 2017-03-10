require 'test_helper'

class TaggingTest < ActiveSupport::TestCase
  # Tests that all default fields of a new tagging are correctly set

  # Declares a new tagging
  def setup
    @tagging = Tagging.new
  end

  # Passes if project id is nil
  test 'project id is nil' do
    assert_default_nil(@tagging, @tagging.project_id)
  end

  # Passes if tag id is nil
  test 'tag id is nil' do
    assert_default_nil(@tagging, @tagging.tag_id)
  end

  # ---------------------------------------------------
  # Testing with fixtures

  test 'tagging project id' do
    assert_equal 1, taggings(:one).project_id
    assert_equal 2, taggings(:two).project_id
  end

  #-----------------------------------------------------------------------------
  # Testing validation

  test 'name presence' do
    @tagging.tag_id = nil
    refute @tagging.valid?
    @tagging.tag_id = 1
    @tagging.project_id = nil
    refute @tagging.valid?
  end
end
