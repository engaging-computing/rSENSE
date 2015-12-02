require 'test_helper'
require_relative 'base_integration_test'

class RenameVisTest < IntegrationTest
  self.use_transactional_fixtures = false

  test 'create modify and delete a vis' do
    login('kcarcia@cs.uml.edu', '12345')

    visit "/projects/#{projects(:dessert).id}"
    click_on 'Visualize'

    find('#save-ctrls > .vis-ctrl-header').click
    assert page.has_content?('Save Visualization')
    save_and_open_page
    find('#save-vis-btn').show
    click_on 'Save Visualization'

    assert(page.has_content?('Please enter a name for this visualization:'),
      'Name modal')
    find('#nname').set('This is a vis')
    click_on 'Finish'

    assert(page.has_content?('Visualization was successfully created.'),
           'Create worked')

    find('.menu_edit_link').click
    assert page.has_content?('Edit Title'), 'Dropdown menu'
    click_on 'Edit Title'

    find('#visualization_title').set('Crazy Vis')
    find('#title-and-menu-edit').find('.btn-success').click

    assert page.has_content?('Visualization was successfully updated.'), 'Save worked'
    assert find('#title-and-menu-title').has_content?('Crazy Vis')

    find('.menu_edit_link').click
    assert page.has_content?('Edit Title'), 'Dropdown menu'
    click_on 'Delete Visualization'

    page.driver.browser.accept_js_confirms
    assert page.has_content?('Visualizations'), 'On vis index'
    assert page.has_no_content?('Crazy Vis'), 'Vis was renamed'
  end
end
