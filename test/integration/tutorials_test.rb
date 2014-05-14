require 'test_helper'

class TutorialsTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'create a tutorial' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Tutorials'
    click_on 'See All Tutorials'
    assert page.has_no_content?('Create Tutorial'), 'Non-Admin should not be able to create a tutorial'

    logout
    login('nixon@whitehouse.gov', '12345')
    visit '/tutorials'
    assert page.has_content?('Create Tutorial'), 'Admin should be able to create a tutorial'

    click_on 'Create Tutorial'
    wait_for_id('new_name')
    find('#new_name').set('Awesome Tutorial')
    click_on 'Finish'
    assert page.has_content?('Awesome Tutorial'), 'Should have ended up on tutorials show page'

    find('#publish_tutorial').click
    visit '/tutorials'
    assert page.has_content?('Awesome Tutorial'), 'Tutorial should have been published'
    click_on 'Awesome Tutorial'
    assert page.has_content?('Publish'), 'Should have ended up on tutorials show page'
    find('#publish_tutorial').click
    visit '/tutorials'
    assert page.has_no_content?('Awesome Tutorial'), 'Tutorial should have been unpublished'

  end
end
