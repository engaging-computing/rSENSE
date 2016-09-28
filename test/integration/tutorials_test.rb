require 'test_helper'
require_relative 'base_integration_test'

class TutorialsTest < IntegrationTest
  test 'create a tutorial' do
    # Make sure a regular user cant create a tutorial
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Tutorials'
    assert page.has_no_content?('New Tutorial'), 'Non-Admin should not be able to create a tutorial'
    logout

    # An Admin should be able to create a Tutorial
    login('nixon@whitehouse.gov', '12345')
    visit '/tutorials'
    assert page.has_content?('New Tutorial'), 'Admin should be able to create a tutorial'
    find('#tutorial_title').set('Awesome Tutorial')
    click_on 'New Tutorial'
    assert page.has_content?('Awesome Tutorial'), 'Tutorial should be on the Tutorial Index Page'
  end
end
