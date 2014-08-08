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
    visit '/'
    click_on 'Projects'
    find('#project_title').set('Contributor Key Test Project')
    click_on 'Create Project'
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
    find('#key').set('test2')
    find('#contributor_name').set('Jake')
    click_on 'Submit Key'
    click_on 'Manual Entry'
    list = page.all(:css, 'th')
    field_id =  list[1]['data-field-id']
    find('#data_set_name').set('Data1')
    find('.validate_number').set('5')
    click_on 'Save'
    assert page.has_content? 'Visualizations'
    click_on 'Contributor Key Test Project'
    visit '/'
    visit '/projects'
    click_on 'Contributor Key Test Project'
    assert page.has_css?('.key')
    click_on 'Clear Key'
    assert page.has_content? 'Login'
    find('#key').set('test1')
    find('#contributor_name').set('Jake')
    click_on 'Submit Key'
    click_on 'Manual Entry'
    find('#data_set_name').set('Data2')
    find('.validate_number').set('5')
    click_on 'Save'
    assert page.has_content? 'Visualizations'
    visit '/projects'
    click_on 'Contributor Key Test Project'
    assert page.has_content? 'Data Sets'
    assert page.has_content? 'Contribute Data'
    temp = page.all(:css, '.key')
    assert_equal temp[0][:title], 'test1'
    assert_equal temp[1][:title], 'test2'
    assert_not_equal(temp[0].find('a').text, temp[1].find('a').text)
    click_on 'Clear Key'
    visit '/projects'
    id = page.all(:css, '.item-title')[0].find('a')[:href].split('/').last
    post "/api/v1/projects/#{id}/jsonDataUpload",

          title: 'Anonymous Data',
          contribution_key: 'test1',
          contributor_name: 'Jake',
          data:
          {
            "#{field_id}" => [5]
          }

    assert_response :success
    visit "/projects/#{id}"
    assert page.has_content? 'Contributor Key Test Project'
    assert page.has_no_css?('.gravatar')
  end
end
