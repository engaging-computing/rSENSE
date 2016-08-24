require 'test_helper'
require_relative 'base_integration_test'

class ContribKeyWithDataSetTest < IntegrationTest
  self.use_transactional_fixtures = false

  test 'website_and_API' do
    login('kcarcia@cs.uml.edu', '12345')

    # Create a Project
    visit '/projects'
    find('#create-project-fab-button').click
    find('#project_title').set('Contributor Key Test Project')
    click_on 'Create Project'

    # Remember the projects ID
    @project_id = current_url.split('/').last

    # Add Fields
    find('#manual_fields').click
    click_on 'Add Number'
    assert page.has_content? 'Number'
    click_on 'Save and Return'
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

  test 'create invalid contributor key' do
    login('kcarcia@cs.uml.edu', '12345')

    project_id = projects(:contributor_key_project).id
    visit "/projects/#{project_id}"
    find('#edit-project-button').click
    click_on 'Create Key'

    assert page.has_content? 'Failed to create Contributor Key'
    assert page.has_content? "Name (Key's Label) is too short (Minimum is one character)"
    assert page.has_content? 'Key is too short (Minimum is one character)'
  end

  test 'use invalid contributor key' do
    project_id = projects(:contributor_key_project).id

    # no contributor key or contributor name
    visit "/projects/#{project_id}"
    click_on 'Submit Key'
    assert page.has_content? 'Invalid contributor key.'
    assert page.has_content? 'Enter a contributor Name.'

    # no contributor name
    visit "/projects/#{project_id}"
    find('#key').set 'key'
    click_on 'Submit Key'
    assert page.has_content? 'Enter a contributor Name.'

    # no contributor key
    visit "/projects/#{project_id}"
    find('#contributor_name').set 'name'
    click_on 'Submit Key'
    assert page.has_content? 'Invalid contributor key.'
  end
end
