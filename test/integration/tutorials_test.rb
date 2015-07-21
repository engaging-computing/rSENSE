require 'test_helper'

class TutorialsTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 2
  end

  teardown do
    finish
  end

  test 'create a tutorial' do
    # Make sure a regular user cant create a tutorial
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'Tutorials'
    click_on 'See All Tutorials'
    assert page.has_no_content?('Create Tutorial'), 'Non-Admin should not be able to create a tutorial'
    logout

    # An Admin should be able to create a Tutorial
    login('nixon@whitehouse.gov', '12345')
    visit '/tutorials'
    assert page.has_content?('Create Tutorial'), 'Admin should be able to create a tutorial'
    find('#tutorial_title').set('Awesome Tutorial')
    click_on 'Create Tutorial'
    assert page.has_content?('Awesome Tutorial'), 'Should have ended up on tutorials show page'

    # An Admin should be able to publish a tutorial.
    find('#publish_tutorial').click
    assert page.has_content?('Tutorial was successfully updated.'), 'Tutorial was not saved.'

    # Once published anyone should be able to see the tutorial
    visit '/tutorials'
    assert page.has_content?('Awesome Tutorial'), 'All tutorials should be visible to admins'
    logout
    visit '/tutorials'
    assert page.has_content?('Awesome Tutorial'), 'Published tutorial should be visible to user'

    # Unpublish the tutorial
    login('nixon@whitehouse.gov', '12345')
    visit '/tutorials'
    click_on 'Awesome Tutorial'
    assert page.has_content?('Description'), 'Should have ended up on tutorials show page'
    find('#publish_tutorial').click
    assert page.has_content?('Tutorial was successfully updated.'), 'Tutorial was not saved.'

    logout
    visit '/tutorials'
    assert page.has_no_content?('Awesome Tutorial'), 'Tutorial should have been unpublished'
  end
end
