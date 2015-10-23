require 'test_helper'
require_relative 'base_integration_test'

class UpdateFieldsTest < IntegrationTest
  test 'edit fields' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Projects'
    find('#project_title').set('Fields Test')
    click_on 'Create Project'

    assert page.has_content?('Fields'), "Project page should have 'Fields'"

    find('#manual_fields').click

    click_on 'Add Number'
    assert page.has_content?('Number'), 'Number field is there'
    click_on 'Add Number'
    page.assert_selector('tr', count: 3)
    first(:css, '.field_delete').click
    find('.field_delete').click

    click_on 'Add Text'
    assert page.has_content?('Text'), 'Text field is there'
    find('.field_delete').click

    click_on 'Add Timestamp'
    assert page.has_content?('Timestamp'), 'Timestamp is there'
    find('.field_delete').click

    click_on 'Add Location'
    assert page.has_content?('Latitude'), 'Latitude is there'
    assert page.has_content?('Longitude'), 'Longitude is there'
    first(:css, '.field_delete').click

    find('#fields_form_submit').click

    assert page.has_content?('Fields were successfully updated.')
  end

  test 'edit fields named correctly' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Projects'
    find('#project_title').set('Field Naming Test')
    click_on 'Create Project'

    assert page.has_content?('Fields'), "Project page should have 'Fields'"

    find('#manual_fields').click

    # Add Fields
    click_on 'Add Number'
    click_on 'Add Text'
    click_on 'Add Timestamp'
    click_on 'Add Location'

    # Verify that they were added
    assert page.has_content?('Number'), 'Number field is there'
    assert page.has_content?('Text'), 'Text field is there'
    assert page.has_content?('Timestamp'), 'Timestamp is there'
    assert page.has_content?('Latitude'), 'Latitude is there'
    assert page.has_content?('Longitude'), 'Longitude is there'

    # Rename Fields
    fill_in 'number_1', with: "apple"
    fill_in 'text_1', with: "banana"
    fill_in 'timestamp', with: "robot"
    fill_in 'latitude', with: "fan"
    fill_in 'longitude', with: "watermelon"

    find('#fields_form_submit').click

    # Verify they were named correctly
    assert page.has_content?('apple')
    assert page.has_content?('banana')
    assert page.has_content?('robot')
    assert page.has_content?('fan')
    assert page.has_content?('watermelon')
  end

  test 'template fields with data set' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Projects'
    find('#project_title').set('Template Fields Test')
    click_on 'Create Project'

    assert page.has_content?('Fields'), "Project page should have 'Fields'"

    # find('#template_file_upload').click

    csv_path = Rails.root.join('test', 'CSVs', 'dessert.csv')
    find('#template_file_form').attach_file('file', csv_path)

    assert page.has_content?('Please select types for each field below.')

    click_on 'Submit'

    assert page.has_content?('dessert')
  end

  test 'teplate fields without data set' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Projects'
    find('#project_title').set('Template Fields Test 2')
    click_on 'Create Project'

    assert page.has_content?('Fields'), "Project page should have 'Fields'"

    # find('#template_file_upload').click

    csv_path = Rails.root.join('test', 'CSVs', 'dessert.csv')
    find('#template_file_form').attach_file('file', csv_path)

    assert page.has_content?('Please select types for each field below.')
    find('#create_dataset').click

    click_on 'Submit'

    assert page.has_content?('Contribute Data')
  end
end
