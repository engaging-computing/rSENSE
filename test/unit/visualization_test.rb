require 'test_helper'

class VisualizationTest < ActiveSupport::TestCase
  # Tests that all default fields of a new visualization are correctly set

  # Declares a new visualization
  def setup
    @visualization = Visualization.new
    @owner = users(:nixon)
  end

  # Passes if hidden is false
  test 'hidden is false' do
    assert_default_false(@visualization, @visualization.hidden)
  end

  # Passes if content is nil
  test 'content is nil' do
    assert_default_nil(@visualization, @visualization.content)
  end

  # Passes if featured is false
  test 'featured is false' do
    assert_default_false(@visualization, @visualization.featured)
  end

  # Passes if featured_at is nil
  test 'featured_at is nil' do
    assert_default_nil(@visualization, @visualization.featured_at)
  end

  # Passes if Visualization ID is nil
  test 'vis_id is nil' do
    assert_default_nil(@visualization, @visualization.id)
  end

  # Passes if title is nil
  test 'title is nil' do
    assert_default_nil(@visualization, @visualization.title)
  end

  # Passes if summary is nil
  test 'summary is nil' do
    assert_default_nil(@visualization, @visualization.summary)
  end

  # Passes if thumb_id is nil
  test 'thumb_id is nil' do
    assert_default_nil(@visualization, @visualization.thumb_id)
  end

  # Passes if created_at is nil
  test 'created_at is nil' do
    assert_default_nil(@visualization, @visualization.created_at)
  end

  # Passes if project_id is nil
  test 'project_id is nil' do
    assert_default_nil(@visualization, @visualization.project_id)
  end

  # Passes if user_id is nil
  test 'user_id is nil' do
    assert_default_nil(@visualization, @visualization.user_id)
  end

  # Passes if summary of a visualization is set properly
  test 'set visualization summary' do
    @visualization.summary = 'Summary'
    assert_equal(@visualization.summary, 'Summary')
    @copy = @visualization
    assert_equal(@visualization.summary, @copy.summary)
  end
end