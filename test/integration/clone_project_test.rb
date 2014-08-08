require 'test_helper'

class CloneProjectTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  def set_cell(ii, val)
    page.execute_script "$($('#manualTable input')[#{ii}]).val(#{val})"
  end

  # Note, currectly does not verify data is cloned correct, just that the sets are cloned
  test 'nixon clones kates project' do
    # #############SETUP#############
    login('kcarcia@cs.uml.edu', '12345')

    click_on 'Projects'

    find('#project_title').set('Das Cloning Projekt')
    click_on 'Create Project'

    find('#manual_fields').click
    find('#new_field').find(:xpath, 'option[2]').select_option
    assert page.has_content?('Field added'), 'Flash happened'
    assert page.has_content?('Number'), 'Number field is there'
    find('#fields_form_submit').click

    click_on 'Manual Entry'
    fill_in 'Dataset Name', with: 'I Like Clones'
    click_on 'Add Row'
    set_cell(0, 47)
    click_on 'Save'

    assert page.has_content?('I Like Clones'), 'Save should succeed'
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    page.execute_script "$('#upload').show()"
    find('.upload_media form').attach_file('upload', img_path)
    assert page.has_content?('nerdboy.jpg'), 'File should be in list'

    click_on 'Das Cloning Projekt'
    img_path = Rails.root.join('test', 'CSVs', 'test.pdf')
    page.execute_script "$('#upload').show()"
    find('.upload_media form').attach_file('upload', img_path)
    assert page.has_content?('test.pdf'), 'File should be in list'

    logout
    # ###########CLONE###############
    login 'nixon@whitehouse.gov', '12345'

    click_on 'Projects'

    click_on 'Das Cloning Projekt'

    click_button 'Clone'
    find('#clone_datasets').set(true)
    find('#project_name').set('Cloned with Data')
    click_on 'Clone Project'

    assert page.has_content?('nerdboy.jpg'), 'File should be in list'
    assert page.has_content?('test.pdf'), 'File should be in list'
    assert page.has_content?('I Like Clones'), 'Dataset should be in list'

    page.find('.dataset').click_on 'Delete'
    page.driver.browser.accept_js_confirms

    page.find('#edit-project-button').click
    click_on 'Delete Project'
    page.driver.browser.accept_js_confirms

    click_on 'Projects'
    assert page.has_no_content?('Cloned with Data'), 'Project Removed from List'
  end
end
