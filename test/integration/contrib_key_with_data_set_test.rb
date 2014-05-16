require 'test_helper'

class ContribKeyWithDataSetTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end
  
  test "setup" do
    login('kcarcia@cs.uml.edu', '12345')
    visit '/'
    click_on 'Projects'
    click_on 'Create Project'
    find('#project_title').set('Contributor Key Test Project')
    click_on 'Create'
    assert page.has_content? 'Project was successfully created.'
    find('#manual_fields').click
    find('#new_field').find(:xpath, 'option[2]').select_option
    assert page.has_content? 'Field added'
    assert page.has_content? 'Number'
    click_on 'Save and Return'
    assert page.has_content? 'Changes to fields saved.'
    find('#edit-project-button').click
    assert page.has_content? 'Back to Project'
    find('#project_lock').click
    click_on 'Submit'
    assert page.has_content? 'Project was successfully updated.'
    find('#edit-project-button').click
    find('#contrib_key_name').set('test1')
    find('#contrib_key_key').set('test1')
    click_on 'Create Key'
    find('#contrib_key_name').set('test2')
    find('#contrib_key_key').set('test2')
    click_on 'Create Key'
    assert page.has_content? 'Added contributor key.'
    click_on 'Back to Project'
    click_on 'Logout'
    assert page.has_content? 'Login'
  end
  test "upload_data" do
    visit '/'
    click_on 'Projects'
    click_on 'Contributor Key Test Project'
    find('#key').set('test2')
    click_on 'Submit Key'
    visit '#{request.request_uri}/manualEntry'
    find('#data_set_name').set('Data1')
    find('#contrib_name').set('Jake')
    find('.validate_number').set('5')
    click_on 'Save'
    assert page.has_content? 'Visualizations'
    click_on 'Contributor Key Test Project'
  end
end
