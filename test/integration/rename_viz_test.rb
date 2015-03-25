require 'test_helper'

class RenameVizTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'create modify and delete a viz' do
    login('kcarcia@cs.uml.edu', '12345')

    click_on 'Projects'
    click_on 'Dessert is Delicious'
    click_on 'Visualize'

    assert page.has_content?('Save Visualization')

    page.execute_script "$('#saveVisButton').click()"

    assert page.has_content?('Please enter a name for this visualization:'), 'Name modal'

    find('#nname').set('This is a viz')
    click_on 'Finish'

    assert page.has_content?('Visualization was successfully created.'), 'Create worked'

    find('.menu_edit_link').click

    assert page.has_content?('Edit Summary'), 'Dropdown menu'

    click_on 'Edit Title'

    find('#visualization_title').set('Crazy Viz')
    find('#title-and-menu-edit').find('.btn-success').click

    assert page.has_content?('Visualization was successfully updated.'), 'Save worked'
    assert find('#title-and-menu-title').has_content?('Crazy Viz')

    find('.menu_edit_link').click

    assert page.has_content?('Edit Summary'), 'Dropdown menu'

    click_on 'Edit Summary'

    find('#visualization_summary').set('The quick brown fox')
    click_on 'Save'

    assert find('#title-and-menu-show-summary').has_content?('The quick brown fox')

    find('.menu_edit_link').click

    assert page.has_content?('Edit Summary'), 'Dropdown menu'

    click_on 'Delete Visualization'

    page.driver.browser.accept_js_confirms

    assert page.has_content?('Visualizations'), 'On viz index'

    assert page.has_no_content?('Crazy Viz'), 'Viz was renamed'
  end
end
