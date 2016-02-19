require 'test_helper'
require_relative 'base_integration_test'

class TemplateFieldsTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project = projects(:template_fields_project)
  end

  test 'template from csv' do
    login('nixon@whitehouse.gov', '12345')
    visit project_path(@project)
    assert page.has_content?('Test for templating fields'), 'Not on project page.'

    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    find(:css, '#template_file_form').attach_file('file', csv_path)
    assert page.has_content?('Please select types for each field below.'), 'Didn\'t find upload button'
    click_on 'Submit'
    visit project_path(@project)
    find('.data_set_edit').click
    # this test checks the dataset edit page instead of the vis because
    # the vis was not rendering properly in capybara.
    assert page.has_content?('-71.36945'), 'Data wasn\'t uploaded.'
  end
end