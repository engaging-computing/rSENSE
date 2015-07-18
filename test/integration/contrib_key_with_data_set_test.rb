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

  test 'website_and_API' do
    login('kcarcia@cs.uml.edu', '12345')

    # Create a Project
    visit '/projects'
    find('#project_title').set('Contributor Key Test Project')
    click_on 'Create Project'

    # Remember the projects ID
    @project_id = current_url.split('/').last

    # Add Fields
    find('#manual_fields').click
    click_on 'Add Number'
    assert page.has_content? 'Number'
    click_on 'Save and Return'
    assert page.has_content? 'Fields were successfully updated.'
    find('#edit-project-button').click
    assert page.has_content? 'Back to Project'
    find('#project_lock').click
    click_on 'Submit'
    assert page.has_content? 'Project was successfully updated.'

    # Add Contributor keys
    find('#edit-project-button').click
    find('#contrib_key_name').set('test1_name')
    find('#contrib_key_key').set('test1_key')
    click_on 'Create Key'
    find('#contrib_key_name').set('test2_name')
    find('#contrib_key_key').set('test2_key')
    click_on 'Create Key'
    assert page.has_content? 'Added contributor key.'
    click_on 'Back to Project'

    # Log out to test contributor keys
    click_on 'Logout'
    assert page.has_content? 'Login'

    # Apply keys
    find('#key').set('test2_key')
    find('#contributor_name').set('Jake')
    click_on 'Submit Key'

    # Contribute Data
    click_on 'Manual Entry'
    list = page.all(:css, '.slick-header-column')
    field_id_long = list[0]['id']
    field_id_pos = field_id_long.rindex(/-/)
    field_id = field_id_long[field_id_pos + 1..-1]
    find('#data_set_name').set('Data1')
    find(:css, '.slick-row:nth-child(1)>.slick-cell.l0.r0').double_click
    find('.editor-text').set('5')
    find('#edit_table_save_2').click
    assert page.has_content? 'Visualizations'

    # Clear the key
    click_on 'Contributor Key Test Project'
    assert page.has_css?('.key')
    click_on 'Clear Key'

    # Test another key
    assert page.has_content? 'Login'
    find('#key').set('test1_key')
    find('#contributor_name').set('John')
    click_on 'Submit Key'
    click_on 'Manual Entry'
    find('#data_set_name').set('Data2')
    find(:css, '.slick-row:nth-child(1)>.slick-cell.l0.r0').double_click
    find('.editor-text').set('5')
    find('#edit_table_save_2').click
    assert page.has_content? 'Visualizations'

    # Make sure data sets were created
    click_on 'Contributor Key Test Project'
    assert page.has_content? 'Data Sets'
    assert page.has_content? 'Contribute Data'
    temp = page.all(:css, '.key')
    assert_equal temp[0][:title], 'test1_name'
    assert_equal temp[1][:title], 'test2_name'
    click_on 'Clear Key'

    # Test API
    post "/api/v1/projects/#{@project_id}/jsonDataUpload",

          title: 'Anonymous Data',
          contribution_key: 'test1_key',
          contributor_name: 'Jake',
          data:
          {
            "#{field_id}" => [5]
          }

    # Make sure it worked
    assert_response :success
    visit "/projects/#{@project_id}"
    assert page.has_content? 'Contributor Key Test Project'
    assert page.has_no_css?('.gravatar')
  end
end
