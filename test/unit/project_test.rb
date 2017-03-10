require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  # Tests that all default fields of a new project are correctly set

  # Declares a new project
  def setup
    @project = Project.new
  end

  # Passes if content is nil
  test 'content is nil' do
    assert_default_nil(@project, @project.content)
  end

  # Passes if cloned_from is nil
  test 'cloned_from is nil' do
    assert_default_nil(@project, @project.cloned_from)
  end

  # Passes if featured if false
  test 'featured is false' do
    assert_default_false(@project, @project.featured)
  end

  # Passes if is_template is false
  test 'is_template is false' do
    assert_default_false(@project, @project.is_template)
  end

  # Passes if filter is ""
  test 'filter is an empty string' do
    assert_equal '', @project.filter, 'Expected project fitler is not an empty string.'
  end

  # Passes if fields.count is equal to 0, which indicated has_fields is false
  test 'fields count is false' do
    assert @project.fields.count == 0, 'Expected project fields count is not 0, so has_fields is not false.'
  end

  # Passes if featured_media_id is nil
  test 'featured_media_id is nil' do
    assert_default_nil(@project, @project.featured_media_id)
  end

  # Passes if hidden is false
  test 'hidden is false' do
    assert_default_false(@project, @project.hidden)
  end

  # Passes if featured_at is nil
  test 'featured_at is nil' do
    assert_default_nil(@project, @project.featured_at)
  end

  # Passes if tags is empty
  test 'tags is empty' do
    assert_empty(@project.tags)
  end

  # ---------------------------------------------------
  # Testing with fixtures

  test 'project title' do
    assert_equal 'Measuring Things', projects(:one).title
  end

  test 'project content' do
    assert_equal 'Sample Content', projects(:one).content
  end

  test 'project cloned_from' do
    assert_nil projects(:one).cloned_from, 'Expected project content is not nil.'
  end

  test 'project featured' do
    assert_equal false, projects(:one).featured, 'Expected project featured is not false.'
  end

  test 'project is_template' do
    assert_equal false, projects(:one).is_template, 'Expected project is_template is not false.'
  end

  test 'project filter' do
    assert_equal '', projects(:one).filter, 'Expected project filter is not an empty string.'
  end

  test 'project featured_media_id' do
    assert_nil projects(:one).featured_media_id, 'Expected project featured_media_id is not nil.'
  end

  #-----------------------------------------------------------------------------
  # Testing validation

  test 'invalid media object id' do
    old_media_id = @project.featured_media_id
    @project.featured_media_id = -1
    refute @project.valid?
    @project.featured_media_id = old_media_id
  end
end
