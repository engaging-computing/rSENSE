require 'test_helper'
require_relative 'base_integration_test'

class MakeProjectTest < IntegrationTest
  test 'kate makes a new project' do
    login('kcarcia@cs.uml.edu', '12345')

    # Add a project
    click_on 'Projects'

    find('#create-project-fab-button').click
    find('#project_title').set('Das Projekt')
    click_on 'Create Project'

    assert page.has_content?('Visualizations'),
      "Project page should have 'Visualizations'"

    assert page.has_content?('Logout'),
      'Should be logged in here'

    click_on 'Projects'
    assert page.has_content?('Templates'), 'Should be on Projects page'
    assert page.has_content?('Das Projekt'), 'New project should be in list'
  end

  test 'search in projects' do
    visit '/projects?utf8=%E2%9C%93&search=Empty&sort=like_count&order=DESC'

    assert page.has_content?('Empty Project'),
      'Search does not find project'

    assert page.has_no_content?('Breaking Things'),
      'Search finds non-matching project.'
  end
end
