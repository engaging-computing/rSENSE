require 'test_helper'

class DeleteThenFeatureMoTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 2
  end

  teardown do
    finish
  end

  test 'delete then feature project mo' do
    login 'nixon@whitehouse.gov', '12345'

    # create a new project to use
    visit '/projects'
    find('#project_title').set('Feature MO Project')
    click_on 'Create Project'

    # upload a media object to the project
    url = page.current_path
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    page.execute_script "$('#upload').show()"
    find('.upload_media form').attach_file('upload', img_path)

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
    find('#project_title').set('Feature MO Project')
    click_on 'Create Project'

    # upload some data so we can save a visualization
    url = page.current_path
    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    page.execute_script "$('#template_file_form').parent().show()"
    find(:css, '#template_file_form').attach_file('file', csv_path)
    find(:css, 'button.btn-primary').click

    # actually save the visualization
    find(:css, '#save-ctrls > .vis-ctrl-header').click
    click_on 'Save Visualization'
    click_on 'Finish'
    assert page.has_content?('Visualization was successfully created.'),
      'Visualization should have been created'

    # upload a media object to the project
    url = page.current_path
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    page.execute_script "$('#upload').show()"
    find('.upload_media form').attach_file('upload', img_path)

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
