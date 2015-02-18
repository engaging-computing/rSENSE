require 'test_helper'
class BugReportTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'get issue report page' do
    visit '/'
    click_on 'Report an Issue'

    assert page.has_content?('Report an Issue: Do you have a GitHub account?'), 'Did not get to report an issue page.'
  end

  test 'get issue report page without account' do
    visit '/report_bug'
    find('#no_github_account').click

    assert page.has_content?('Report an Issue'), 'Should have redirected to github for authorization'
  end

  test 'get issue report page with github account not logged in' do
    visit '/report_bug'
    find('#github_account').click

    assert page.has_content?('Log in to iSENSE'), 'Should have redirected to github for authorization'
  end
end