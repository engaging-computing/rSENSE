require 'test_helper'

class TagTest < ActiveSupport::TestCase
  # Tests that all default fields of a new tag are correctly set

  # Declares a new tag
  def setup
    @tag = Tag.new
  end

  # Passes if name is nil
  test 'name is nil' do
    assert_default_nil(@tag, @tag.name)
  end

  # ---------------------------------------------------
  # Testing with fixtures

  test 'tag title' do
    assert_equal 'Science', tags(:one).name
  end

  #-----------------------------------------------------------------------------
  # Testing validation

  test 'name presence' do
    @tag.name = ''
    refute @tag.valid?
  end
end
