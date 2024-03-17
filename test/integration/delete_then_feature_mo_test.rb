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
end
