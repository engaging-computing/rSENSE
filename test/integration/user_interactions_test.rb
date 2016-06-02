# Put tests based on how the user interacts with the site here
require 'test_helper'
require_relative 'base_integration_test'

class UserInteractionsTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @slick_project = projects(:slickgrid_project)
  end

  test 'edit button should not show on projects you don\'t own' do
    visit project_path(@slick_project)
    assert page.has_no_content?('Edit'), 'Edit button appears on project without being logged in'
    login('pson@cs.uml.edu', '12345')
    visit project_path(@slick_project)
    assert page.has_no_content?('Edit'), 'Edit button appears on project that the user does not own.'
  end

  test 'try to inject code into data set' do
    # Make sure that code injection cannot happen anymore
    login('pson@cs.uml.edu', '12345')

    click_on 'Projects'
    find('#project_title').set('Code Injection Test')
    click_on 'Create Project'

    find('#manual_fields').click
    click_on 'Add Text'
    fill_in 'text_1', with: '<script>alert(1)</script>'
    click_on 'Save and Return'

    assert page.has_no_content?('<script>'), 'Users should not be able to inject code into the webpage.'

    click_on 'Manual Entry'
    first('.editor-text').set('<h1>Testing...</h1>')
    find('#edit_table_save_1').click

    assert page.has_no_content?('<h1>'), 'Users should not be able to inject code into the webpage.'
  end
end
