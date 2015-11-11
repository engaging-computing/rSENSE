require 'test_helper'
require_relative 'base_integration_test'

class UploadDataTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project = projects(:lots_of_data_sets)
  end

  test 'correct number of data sets' do
    visit project_path(@project)
    assert page.has_content?('Lots of Data Sets'), 'Not on project page.'

    all('input[type="checkbox"]')[0].click
    all('input[type="checkbox"]')[1].click

    click_on('Visualize')

    assert page.has_content?('Showing 4 Data Sets'), 'Showing wrong number of data sets.'
  end
end