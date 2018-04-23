require 'test_helper'
require_relative 'base_integration_test'

class DeleteSelectedDataSetsTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project = projects(:delete_data_sets)
  end

  def navigate_to_project
    login('pson@cs.uml.edu', 12345)
    visit project_path(@project)
  end

  test 'delete selected data sets' do
    navigate_to_project

    find('#lbl_102').click
    message = accept_confirm do
      find('#delete_selected_button').click
    end
    assert message == 'Are you sure you want to delete 2 data sets?', 'User was not given confirmation box.'

    assert page.has_no_content?('pat-1'), 'Data set 1 was not deleted'
    assert page.has_no_content?('pat-2'), 'Data set 2 was not deleted'
    assert page.has_content?('nixon-1'), 'Wrong data set was deleted'
  end

  test 'try to delete another user\'s data set' do
    navigate_to_project

    message = accept_alert do
      find('#delete_selected_button').click
    end
    # If the test doesn't reach this point, then it means it was given the 'Are you sure' dialog instead of the alert.
    assert message == 'You have selected another user\'s data set. You may only delete data sets that belong to you.',
      'User was not given warning alert'
  end

  test 'delete selected button hidden when logged out' do
    visit project_path(@project)
    assert page.has_no_content?('#delete_selected_button'), 'Delete Selected button should not be displayed when the user is logged out'
  end

  test 'page should reload if last dataset deleted' do
    login('kcarcia@cs.uml.edu', 12345)
    visit project_path(projects(:dessert))
    accept_confirm do
      first('.data_set_delete').click
    end
    assert page.has_content?('This project has no data yet.'), 'Page didnt reload when last dset was deleted'
  end
end
