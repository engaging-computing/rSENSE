require 'test_helper'
require_relative 'base_integration_test'

class DeleteThenFeatureMoTest < IntegrationTest
  test 'delete then feature project mo' do
    login 'nixon@whitehouse.gov', '12345'

    # create a new project to use
    visit '/projects'
    find('#create-project-fab-button').click
    find('#project_title').set('Feature MO Project')
    click_on 'Create Project'

    # upload a media object to the project
    url = page.current_path
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    drop_in_dropzone img_path

    assert page.has_content?('Delete'),
        'Media not added.'

    # open a new tab/window thing
    within_window open_new_window do
      visit url
      accept_confirm do
        click_on 'Delete'
      end
      assert page.has_content?('Deleted'),
        'Media Object should have been deleted'
    end

    find(:css, 'input[type=radio]').click
    assert page.has_content?('That media object no longer exists.'),
      'Error should have been shown'
  end

  test 'delete then feature visualization mo' do
    login 'nixon@whitehouse.gov', '12345'

    # create a new project to use
    visit '/projects'
    find('#create-project-fab-button').click
    find('#project_title').set('Feature MO Project')
    click_on 'Create Project'

    # upload some data so we can save a visualization
    url = page.current_path
    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    find(:css, '#template_file_form').attach_file('file', csv_path)
    find(:css, 'button.btn-primary').click

    # Assuming you are within a Capybara test context
    # This will output the current URL to the console
    puts current_url

    # You can also assign it to a variable if you need to perform further checks
    current_url = page.current_url

    expected_url_regex = %r{/projects/\d+/data_sets/\d+}

    # Asserting that the current URL matches the expected URL pattern
    assert_match expected_url_regex, current_url
        
    # actually save the visualization
    find(:css, '#save-ctrls > .vis-ctrl-header', wait: 10).click
    click_on 'Save Visualization'
    click_on 'Finish'
    assert page.has_content?('Visualization was successfully created.'),
      'Visualization should have been created'

    # upload a media object to the project
    url = page.current_path
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    drop_in_dropzone img_path

    assert page.has_content?('Delete'),
        'Media not added.'

    # open a new tab/window thing
    within_window open_new_window do
      visit url
      accept_confirm do
        click_on 'Delete'
      end
      assert page.has_content?('Deleted'),
        'Media Object should have been deleted'
    end

    find(:css, 'input[type=radio]').click
    assert page.has_content?('That media object no longer exists.'),
      'Error should have been shown'
  end
end
