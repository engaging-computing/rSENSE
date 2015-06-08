require 'test_helper'

class MakeProjectTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 2
  end

  teardown do
    finish
  end

  test 'kate makes a new project' do
    login('kcarcia@cs.uml.edu', '12345')

    # Add a project
    click_on 'Projects'

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
    visit '/'
    click_on 'Projects'
    select 'Rating', from: 'sort'
    fill_in 'search', with: 'Empty'
    find(:css, '.fa-search').click

    assert page.has_content?('Empty Project'),
      'Search does not find project'

    assert page.has_no_content?('Breaking Things'),
      'Search finds non-matching project.'
  end
end
