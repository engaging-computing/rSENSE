require 'test_helper'
require_relative 'base_integration_test'

class AnnotationTest < IntegrationTest
  self.use_transactional_fixtures = false

  # Tests as much as possible in HighCharts
  test 'block annotation' do
    @project = projects(:dessert)

    visit project_path(@project)

    assert page.has_content?('Dessert is Delicious'), 'Not on project page.'

    click_on('Visualize')

    click_on('Scatter')

    find('#add-annotation-button').click
    assert page.has_content?('Please enter a comment'), 'Dialog did not appear.'
    assert page.has_content?('TIP: Select a point'), 'Not creating the right type of annotation.'

    find('.ui-icon-check').click
    assert !page.has_content?('Please enter a comment'), 'Dialog did not close.'

    assert page.has_content?('New Annotation'), 'Annotation was not created.'

  end
end