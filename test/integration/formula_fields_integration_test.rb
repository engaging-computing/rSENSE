require 'test_helper'
require_relative 'base_integration_test'

class FormulaFieldsIntegrationTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project = projects(:weather_data)
  end

  test 'create formula fields' do
    login('pson@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Weather Data'), 'Not on project page.'

    csv_path = Rails.root.join('test', 'CSVs', 'weather-data.csv')
    find(:css, '#template_file_form').attach_file('file', csv_path)
    assert page.has_content?('Please select types for each field below.'), 'Didn\'t find upload button'
    click_on 'Submit'
    visit project_path(@project)
    assert page.has_content?('weather-data'), 'Data was not uploaded'
    assert page.has_content?('Event'), 'Fields were not templated'

    find('#manual_formula_fields').click
    click_on 'Add Text'
    find('td input').set 'Jacket'
    find('.field_edit_formula').click
    find('#formula-text').set 'if(Event == "Snow", "Winter Coat", if(Event == "Rain", "Rain Jacket", if(Meantemp < 50, "Sweatshirt", "No Jacket")))'
    find('#formula-save').click

    click_on 'Add Number'
    first('td input').set 'Temperature Range'
    first('.field_edit_formula').click
    find('#formula-text').set 'Maxtemp - Mintemp'
    find('#formula-save').click
    find('#fields_form_submit').click

    assert page.has_content?('Weather Data'), 'Did not get redirected to project page.'
    assert page.has_content?('Jacket'), 'Formula Fields were not saved'

    click_on 'Visualize'
    find('#vis-tab-table').click
    assert page.has_content?('No Jacket'), 'Some data was computed wrong (text)'
    assert page.has_content?('Winter Coat'), 'Some data was computed wrong (text)'
    assert page.has_content?('19.56'), 'Some data was computed wrong (number)'
  end
end
