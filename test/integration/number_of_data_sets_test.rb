require 'test_helper'
require 'capybara-screenshot'
require_relative 'base_integration_test'

class UploadDataTest < IntegrationTest
  self.use_transactional_fixtures = false

  test 'correct number of data sets' do
    @project = projects(:lots_of_data_sets)

    visit project_path(@project)
    screenshot_and_open_image
    assert page.has_content?('Lots of Data Sets'), 'Not on project page.'

    first('.mdl-checkbox ').click
    all('.mdl-checkbox ').last.click

    click_on('Visualize')

    assert page.has_content?('Showing 4 Data Sets'), 'Showing wrong number of data sets.'
  end
end