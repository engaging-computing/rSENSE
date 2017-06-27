require 'test_helper'
require_relative 'base_integration_test'

class ControlTip < IntegrationTest
  self.use_transactional_fixtures = false

  test 'gives grouping suggestions' do
    @project = projects(:votes)

    visit project_path(@project)

    assert page.has_content?('Favorite Pet'), 'Not on project page.'

    click_on('Visualize')

    click_on('Bar')

    assert page.has_content?('Bar graph not looking helpful?'), 'Grouping suggestion did not appear.'

    click_on('Pet')

    assert !page.has_content?('Bar graph not looking helpful?'), 'Grouping suggestion did not disappear.'

  end
end