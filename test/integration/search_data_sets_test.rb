require 'test_helper'

class EditProjDescTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    @project = projects(:one)
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'search data sets' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    fill_in('search', with: 'two')

    # confirm you can leave the project page
    find('#search').click

    assert page.has_content?('two'),
      'Search does not find data set'

    assert page.has_no_content?('one'),
      'Search finds non-matching data set.'
  end

  test 'search data sets no matches' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    fill_in('search', with: 'there is no matches')

    # confirm you can leave the project page
    find('#search').click

    assert page.has_content?('No Matching Data Sets.'),
      'Found data sets when it should not have'

    assert page.has_no_content?('one'),
      'Search finds non-matching data set.'
  end
end