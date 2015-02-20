require 'test_helper'

class UpdateFieldsTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'edit fields' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Projects'
    find('#project_title').set('Fields Test')
    click_on 'Create Project'

    assert page.has_content?('Fields'), "Project page should have 'Fields'"

    find('#manual_fields').click

    click_on 'Add Number'
    assert page.has_content?('Field added'), 'Flash happened'
    assert page.has_content?('Number'), 'Number field is there'
    click_on 'Add Number'
    assert page.has_content?('Field added'), 'Flash happened'
    page.assert_selector('tr', count: 3)
    first(:css, '.field_delete').click
    find('.field_delete').click

    click_on 'Add Text'
    assert page.has_content?('Field added'), 'Flash happened'
    find('.field_delete').click

    click_on 'Add Timestamp'
    assert page.has_content?('Field added'), 'Flash happened'
    find('.field_delete').click

    click_on 'Add Location'
    assert page.has_content?('Field added'), 'Flash happened'
    first(:css, '.field_delete').click

    find('#fields_form_submit').click

    assert page.has_content?('Changes to fields saved.')

  end

  test 'template fields with dataset' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Projects'
    find('#project_title').set('Template Fields Test')
    click_on 'Create Project'

    assert page.has_content?('Fields'), "Project page should have 'Fields'"

    # find('#template_file_upload').click

    csv_path = Rails.root.join('test', 'CSVs', 'dessert.csv')
    page.execute_script "$('#template_file_form').parent().show()"
    find('#template_file_form').attach_file('file', csv_path)
    page.execute_script "$('#template_file_form').submit()"

    assert page.has_content?('Please select types for each field below.')

    click_on 'Submit'

    assert page.has_content?('dessert')
  end

  test 'teplate fields without dataset' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Projects'
    find('#project_title').set('Template Fields Test 2')
    click_on 'Create Project'

    assert page.has_content?('Fields'), "Project page should have 'Fields'"

    # find('#template_file_upload').click

    csv_path = Rails.root.join('test', 'CSVs', 'dessert.csv')
    page.execute_script "$('#template_file_form').parent().show()"
    find('#template_file_form').attach_file('file', csv_path)
    page.execute_script "$('#template_file_form').submit()"

    assert page.has_content?('Please select types for each field below.')
    find('#create_dataset').click

    click_on 'Submit'

    assert page.has_content?('Contribute Data')
  end
end
