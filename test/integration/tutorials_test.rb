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

    find('#tutorial_title').set('Awesome Tutorial')
    click_on 'Create Tutorial'

    assert page.has_content?('Awesome Tutorial'), 'Should have ended up on tutorials show page'

    find('#publish_tutorial').click

    assert page.has_content?('Saved.'), 'Tutorial was not saved.'

    visit '/tutorials'
    assert page.has_content?('Awesome Tutorial'), 'Tutorial should have been published'

    page.execute_script('$($("span:contains(Awesome Tutorial)").closest("div.item-desc").find("a"))[0].click()')
    # click_on 'Awesome Tutorial'
    assert page.has_content?('Publish'), 'Should have ended up on tutorials show page'
    find('#publish_tutorial').click

    assert page.has_content?('Saved.'), 'Tutorial was not saved.'

    visit '/tutorials'
    assert page.has_no_content?('Awesome Tutorial'), 'Tutorial should have been unpublished'
  end
end
